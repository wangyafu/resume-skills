from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def _run(cmd: list[str], *, cwd: Path | None = None) -> None:
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


def _find_chrome() -> Path | None:
    candidates = []
    program_files = os.environ.get("ProgramFiles")
    if program_files:
        candidates.append(Path(program_files) / "Google/Chrome/Application/chrome.exe")
    program_files_x86 = os.environ.get("ProgramFiles(x86)")
    if program_files_x86:
        candidates.append(Path(program_files_x86) / "Google/Chrome/Application/chrome.exe")
    for candidate in candidates:
        if candidate.exists():
            return candidate
    found = shutil.which("chrome") or shutil.which("chrome.exe")
    return Path(found) if found else None


def _paper_css(paper: str) -> str:
    size = "A4" if paper.upper() == "A4" else "Letter"
    return (
        "<style>\n"
        "  @page { size: "
        + size
        + "; margin: 12mm; }\n"
        "  html, body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }\n"
        "</style>\n"
    )


def _ensure_html_has_page_size(html_path: Path, paper: str) -> Path:
    content = html_path.read_text(encoding="utf-8", errors="replace")
    # If user already defines @page size, do nothing.
    if "@page" in content and "size" in content:
        return html_path

    injected = content
    css = _paper_css(paper)
    lower = content.lower()
    head_idx = lower.find("<head")
    if head_idx != -1:
        head_close = lower.find("</head>", head_idx)
        if head_close != -1:
            injected = content[:head_close] + css + content[head_close:]
        else:
            injected = css + content
    else:
        injected = css + content

    tmp = Path(tempfile.mkdtemp(prefix="resume_studio_html_"))
    out = tmp / html_path.name
    out.write_text(injected, encoding="utf-8")
    return out


def _html_to_pdf(in_path: Path, out_pdf: Path, paper: str, chrome_path: Path | None) -> None:
    chrome = chrome_path or _find_chrome()
    if not chrome or not chrome.exists():
        raise RuntimeError(
            "Chrome not found. Install Google Chrome or put chrome.exe on PATH."
        )

    in_path = _ensure_html_has_page_size(in_path, paper)
    out_pdf.parent.mkdir(parents=True, exist_ok=True)

    file_url = in_path.resolve().as_uri()
    cmd = [
        str(chrome),
        "--headless=new",
        "--disable-gpu",
        "--no-first-run",
        "--no-default-browser-check",
        "--disable-extensions",
        f"--print-to-pdf={out_pdf.resolve()}",
        "--print-to-pdf-no-header",
        file_url,
    ]
    _run(cmd)


def _typst_to_pdf(in_path: Path, out_pdf: Path) -> None:
    typst = shutil.which("typst")
    if not typst:
        raise RuntimeError("typst not found on PATH.")
    out_pdf.parent.mkdir(parents=True, exist_ok=True)
    _run([typst, "compile", str(in_path), str(out_pdf)])


def _latex_to_pdf(in_path: Path, out_pdf: Path, workdir: Path | None = None) -> None:
    latexmk = shutil.which("latexmk")
    if not latexmk:
        raise RuntimeError("latexmk not found on PATH.")

    out_pdf.parent.mkdir(parents=True, exist_ok=True)
    build_dir = Path(tempfile.mkdtemp(prefix="resume_studio_latex_"))

    try:
        _run(
            [
                latexmk,
                "-xelatex",
                "-interaction=nonstopmode",
                "-halt-on-error",
                "-outdir=" + str(build_dir),
                str(in_path.resolve()),
            ],
            cwd=workdir,
        )
        produced = build_dir / (in_path.stem + ".pdf")
        if not produced.exists():
            raise RuntimeError("latexmk finished but PDF not found: " + str(produced))
        shutil.copyfile(produced, out_pdf)
    finally:
        shutil.rmtree(build_dir, ignore_errors=True)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Compile HTML/Typst/LaTeX resume to PDF.")
    parser.add_argument("--in", dest="in_path", required=True, help="Input .html/.typ/.tex")
    parser.add_argument("--out", dest="out_pdf", required=True, help="Output PDF path")
    parser.add_argument("--paper", choices=["A4", "Letter"], default="A4")
    parser.add_argument(
        "--engine",
        choices=["auto", "chrome", "typst", "latexmk"],
        default="auto",
        help="Compilation engine.",
    )
    parser.add_argument(
        "--chrome",
        dest="chrome",
        default="",
        help="Optional explicit path to chrome.exe",
    )
    args = parser.parse_args(argv)

    in_path = Path(args.in_path).expanduser().resolve()
    out_pdf = Path(args.out_pdf).expanduser().resolve()
    if not in_path.exists():
        raise FileNotFoundError(str(in_path))

    suffix = in_path.suffix.lower()
    engine = args.engine
    if engine == "auto":
        if suffix in (".html", ".htm"):
            engine = "chrome"
        elif suffix == ".typ":
            engine = "typst"
        elif suffix == ".tex":
            engine = "latexmk"
        else:
            raise ValueError(f"Unsupported input extension for auto: {suffix}")

    chrome_path = Path(args.chrome) if args.chrome else None
    if engine == "chrome":
        _html_to_pdf(in_path, out_pdf, args.paper, chrome_path)
    elif engine == "typst":
        _typst_to_pdf(in_path, out_pdf)
    elif engine == "latexmk":
        _latex_to_pdf(in_path, out_pdf)
    else:
        raise ValueError("Unknown engine: " + str(engine))

    print(str(out_pdf))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except Exception as exc:
        print(f"[render_pdf.py] ERROR: {exc}", file=sys.stderr)
        raise

