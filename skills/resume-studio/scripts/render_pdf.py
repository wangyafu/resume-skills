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
        "  @page { size: " + size + "; }\n"
        "  html, body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }\n"
        "</style>\n"
    )


def _ensure_html_has_page_size(html_path: Path, paper: str) -> Path:
    content = html_path.read_text(encoding="utf-8", errors="replace")
    lower = content.lower()

    # If the document already defines @page rules, don't override them.
    # Browser "extra margins" should be controlled by the document's own print CSS.
    if "@page" in lower:
        return html_path

    # Otherwise inject a minimal print rule:
    # - set the paper size
    # - set @page margin to 0 to avoid browser defaults
    css = _paper_css(paper).replace("@page { size: ", "@page { size: ").replace("; }\n", "; margin: 0; }\n", 1)
    injected = content
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


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Compile HTML resume to PDF.")
    parser.add_argument("--in", dest="in_path", required=True, help="Input .html/.htm")
    parser.add_argument("--out", dest="out_pdf", required=True, help="Output PDF path")
    parser.add_argument("--paper", choices=["A4", "Letter"], default="A4")
    parser.add_argument(
        "--engine",
        choices=["auto", "chrome"],
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
        if suffix not in (".html", ".htm"):
            raise ValueError(f"Unsupported input extension: {suffix} (HTML only)")
        engine = "chrome"

    chrome_path = Path(args.chrome) if args.chrome else None
    if engine == "chrome":
        _html_to_pdf(in_path, out_pdf, args.paper, chrome_path)
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

