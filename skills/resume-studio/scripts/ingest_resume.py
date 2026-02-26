from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def _run(cmd: list[str], *, cwd: Path | None = None) -> str:
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


def _pdf_to_text(pdf: Path, out_txt: Path) -> None:
    tool = shutil.which("pdftotext")
    if not tool:
        raise RuntimeError("pdftotext not found on PATH (poppler).")
    _run([tool, "-layout", str(pdf), str(out_txt)])


def _pdf_to_html(pdf: Path, out_dir: Path) -> Path:
    tool = shutil.which("pdftohtml")
    if not tool:
        raise RuntimeError("pdftohtml not found on PATH (poppler).")
    out_dir.mkdir(parents=True, exist_ok=True)
    # pdftohtml outputs multiple files; we return the main .html if present.
    _run([tool, "-noframes", "-hidden", "-enc", "UTF-8", str(pdf), str(out_dir / "layout")])
    htmls = sorted(out_dir.glob("layout*.html"))
    return htmls[0] if htmls else out_dir


def _docx_to_text(docx: Path, out_txt: Path) -> None:
    tool = shutil.which("pandoc")
    if not tool:
        raise RuntimeError("pandoc not found on PATH.")
    _run([tool, str(docx), "-t", "plain", "-o", str(out_txt)])


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="Ingest an old resume to temporary text for agent use (not for delivery)."
    )
    parser.add_argument("--in", dest="in_path", required=True, help="Input resume file")
    parser.add_argument(
        "--with-layout",
        action="store_true",
        help="For PDF: also run pdftohtml to get a layout reference.",
    )
    parser.add_argument(
        "--workdir",
        default="",
        help="Optional work directory (default: auto temp dir).",
    )
    parser.add_argument(
        "--keep-workdir",
        action="store_true",
        help="Keep temporary workdir (default: delete at end).",
    )
    args = parser.parse_args(argv)

    in_path = Path(args.in_path).expanduser().resolve()
    if not in_path.exists():
        raise FileNotFoundError(str(in_path))

    workdir = Path(args.workdir).expanduser().resolve() if args.workdir else None
    created_temp = False
    if workdir is None:
        workdir = Path(tempfile.mkdtemp(prefix="resume_studio_ingest_"))
        created_temp = True
    else:
        workdir.mkdir(parents=True, exist_ok=True)

    content_txt = workdir / "content.txt"
    layout_ref: Path | None = None

    try:
        suffix = in_path.suffix.lower()
        if suffix == ".pdf":
            _pdf_to_text(in_path, content_txt)
            if args.with_layout:
                layout_ref = _pdf_to_html(in_path, workdir / "layout")
        elif suffix == ".docx":
            _docx_to_text(in_path, content_txt)
        elif suffix in (".html", ".htm", ".tex", ".typ", ".md", ".txt"):
            # Best-effort: treat as text source.
            content_txt.write_text(in_path.read_text(encoding="utf-8", errors="replace"), encoding="utf-8")
        else:
            raise ValueError(f"Unsupported input: {suffix}")

        print(f"WORKDIR={workdir}")
        print(f"CONTENT_TXT={content_txt}")
        if layout_ref:
            print(f"LAYOUT_REF={layout_ref}")
        return 0
    finally:
        if created_temp and not args.keep_workdir:
            shutil.rmtree(workdir, ignore_errors=True)


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except Exception as exc:
        print(f"[ingest_resume.py] ERROR: {exc}", file=sys.stderr)
        raise

