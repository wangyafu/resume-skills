from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path


def _run_capture(cmd: list[str], *, cwd: Path | None = None) -> str:
    proc = subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if proc.returncode != 0:
        raise RuntimeError(f"Command failed ({proc.returncode}): {cmd}\n\n{proc.stdout}")
    return proc.stdout


def _count_pages_pdfinfo(pdf_path: Path) -> int:
    exe = shutil.which("pdfinfo")
    if not exe:
        raise RuntimeError("pdfinfo not found on PATH.")

    out = _run_capture([exe, str(pdf_path)])
    m = re.search(r"^Pages:\s+(\d+)\s*$", out, flags=re.MULTILINE)
    if not m:
        raise RuntimeError(f"Unable to parse page count from pdfinfo output: {pdf_path}")
    return int(m.group(1))


def _count_pages_pypdf(pdf_path: Path) -> int:
    try:
        from pypdf import PdfReader  # type: ignore
    except Exception as exc:  # pragma: no cover
        raise RuntimeError("pypdf not available. Install via: pip install pypdf") from exc

    reader = PdfReader(str(pdf_path))
    return len(reader.pages)


def _count_pages(pdf_path: Path, engine: str) -> int:
    if engine == "pdfinfo":
        return _count_pages_pdfinfo(pdf_path)
    if engine == "pypdf":
        return _count_pages_pypdf(pdf_path)
    if engine == "auto":
        if shutil.which("pdfinfo"):
            return _count_pages_pdfinfo(pdf_path)
        return _count_pages_pypdf(pdf_path)
    raise ValueError("Unknown engine: " + engine)


def _collect_pdfs(in_path: Path, pattern: str, recursive: bool) -> list[Path]:
    if in_path.is_file():
        if in_path.suffix.lower() != ".pdf":
            raise ValueError(f"Input is not a PDF file: {in_path}")
        return [in_path]
    if in_path.is_dir():
        files = in_path.rglob(pattern) if recursive else in_path.glob(pattern)
        out = [p for p in files if p.is_file() and p.suffix.lower() == ".pdf"]
        out.sort()
        return out
    raise FileNotFoundError(str(in_path))


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Get PDF page counts.")
    parser.add_argument(
        "--in",
        dest="in_path",
        required=True,
        help="Input PDF file path or directory",
    )
    parser.add_argument(
        "--glob",
        dest="glob_pattern",
        default="*.pdf",
        help='When --in is a directory, file pattern to match (default: "*.pdf")',
    )
    parser.add_argument(
        "--recursive",
        action="store_true",
        help="When --in is a directory, search recursively",
    )
    parser.add_argument(
        "--engine",
        choices=["auto", "pdfinfo", "pypdf"],
        default="auto",
        help="Page count backend (default: auto)",
    )
    parser.add_argument(
        "--total",
        action="store_true",
        help="Print total page count summary",
    )
    args = parser.parse_args(argv)

    in_path = Path(args.in_path).expanduser().resolve()
    pdf_files = _collect_pdfs(in_path, args.glob_pattern, args.recursive)
    if not pdf_files:
        raise FileNotFoundError(f"No PDF files matched: {in_path}")

    total = 0
    for pdf in pdf_files:
        pages = _count_pages(pdf, args.engine)
        total += pages
        print(f"{pdf}\t{pages}")

    if args.total:
        print(f"TOTAL\t{total}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except Exception as exc:
        print(f"[pdf_page_count.py] ERROR: {exc}", file=sys.stderr)
        raise
