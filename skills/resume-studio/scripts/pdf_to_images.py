from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class PageRange:
    first: int | None  # 1-based, inclusive
    last: int | None  # 1-based, inclusive


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


def _parse_pages(pages: str) -> list[int]:
    s = pages.strip()
    if not s:
        return []
    out: set[int] = set()
    for part in re.split(r"[,\s]+", s):
        if not part:
            continue
        if "-" in part:
            a_str, b_str = part.split("-", 1)
            a = int(a_str)
            b = int(b_str)
            if a <= 0 or b <= 0:
                raise ValueError("Page numbers must be >= 1")
            if b < a:
                a, b = b, a
            for n in range(a, b + 1):
                out.add(n)
        else:
            n = int(part)
            if n <= 0:
                raise ValueError("Page numbers must be >= 1")
            out.add(n)
    return sorted(out)


def _normalize_image_format(fmt: str) -> str:
    fmt = fmt.lower().strip(".")
    if fmt in ("jpg", "jpeg"):
        return "jpg"
    if fmt == "png":
        return "png"
    raise ValueError("Unsupported --format. Use png or jpg.")


def _engine_auto() -> str:
    try:
        import fitz  # type: ignore # noqa: F401

        return "pymupdf"
    except Exception:
        pass

    if shutil.which("pdftoppm"):
        return "pdftoppm"
    if shutil.which("magick"):
        return "magick"
    return "none"


def _render_pymupdf(
    *,
    in_pdf: Path,
    out_dir: Path,
    fmt: str,
    dpi: int,
    jpg_quality: int,
    pages: list[int],
    prefix: str,
) -> None:
    try:
        import fitz  # type: ignore
    except Exception as exc:  # pragma: no cover
        raise RuntimeError(
            "PyMuPDF not available. Install it via: pip install pymupdf"
        ) from exc

    out_dir.mkdir(parents=True, exist_ok=True)

    doc = fitz.open(in_pdf)  # type: ignore[attr-defined]
    try:
        total_pages = doc.page_count
        to_render = pages or list(range(1, total_pages + 1))
        to_render = [p for p in to_render if 1 <= p <= total_pages]
        if not to_render:
            raise ValueError("No pages selected to render.")

        pad = max(2, len(str(total_pages)))
        for page_no in to_render:
            page = doc.load_page(page_no - 1)
            pix = page.get_pixmap(dpi=dpi)
            out_path = out_dir / f"{prefix}{page_no:0{pad}d}.{fmt}"

            # PyMuPDF supports saving to PNG/JPEG, but older versions differ a bit.
            if fmt == "jpg":
                try:
                    pix.save(str(out_path), jpg_quality=jpg_quality)
                except TypeError:
                    pix.save(str(out_path))
            else:
                pix.save(str(out_path))
    finally:
        doc.close()


def _render_pdftoppm(
    *,
    in_pdf: Path,
    out_dir: Path,
    fmt: str,
    dpi: int,
    pages: list[int],
    prefix: str,
) -> None:
    exe = shutil.which("pdftoppm")
    if not exe:
        raise RuntimeError("pdftoppm not found on PATH.")

    out_dir.mkdir(parents=True, exist_ok=True)

    if pages:
        page_range = PageRange(first=min(pages), last=max(pages))
    else:
        page_range = PageRange(first=None, last=None)

    mode_flag = "-png" if fmt == "png" else "-jpeg"
    cmd = [exe, "-r", str(dpi), mode_flag]
    if page_range.first is not None:
        cmd += ["-f", str(page_range.first)]
    if page_range.last is not None:
        cmd += ["-l", str(page_range.last)]

    # pdftoppm writes to <prefix>-<page>.<ext> in cwd.
    # We'll normalize naming afterwards if needed.
    tmp_prefix = f"{prefix}page"
    cmd += [str(in_pdf), tmp_prefix]
    _run(cmd, cwd=out_dir)

    # If user specified sparse pages (e.g. 1,3,5), delete unwanted ones.
    if pages:
        keep = {p for p in pages}
        pattern = re.compile(rf"^{re.escape(tmp_prefix)}-(\d+)\.{re.escape(fmt)}$", re.I)
        for p in out_dir.iterdir():
            m = pattern.match(p.name)
            if not m:
                continue
            n = int(m.group(1))
            if n not in keep:
                p.unlink(missing_ok=True)


def _render_magick(
    *,
    in_pdf: Path,
    out_dir: Path,
    fmt: str,
    dpi: int,
    pages: list[int],
    prefix: str,
) -> None:
    exe = shutil.which("magick")
    if not exe:
        raise RuntimeError("ImageMagick `magick` not found on PATH.")

    out_dir.mkdir(parents=True, exist_ok=True)

    # ImageMagick is 0-based for the [index] syntax.
    # We'll render one page per invocation for predictable naming.
    if pages:
        to_render = pages
    else:
        # For "all pages" we need page count; avoid doing that here.
        # Ask user to install PyMuPDF/pdftoppm instead of doing an expensive guess.
        raise RuntimeError(
            "magick engine requires explicit --pages. "
            "Install PyMuPDF (pip install pymupdf) or use pdftoppm for full-document export."
        )

    pad = max(2, len(str(max(to_render))))
    for page_no in to_render:
        idx = page_no - 1
        out_path = out_dir / f"{prefix}{page_no:0{pad}d}.{fmt}"
        _run(
            [
                exe,
                "-density",
                str(dpi),
                f"{in_pdf}[{idx}]",
                str(out_path),
            ]
        )


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="Split a PDF into per-page images (PNG/JPG)."
    )
    parser.add_argument("--in", dest="in_pdf", required=True, help="Input PDF path")
    parser.add_argument("--outdir", required=True, help="Output directory")
    parser.add_argument("--format", default="png", help="png or jpg (default: png)")
    parser.add_argument("--dpi", type=int, default=200, help="Render DPI (default: 200)")
    parser.add_argument(
        "--pages",
        default="",
        help='Optional page selection, e.g. "1-3,5,7". Default: all pages.',
    )
    parser.add_argument(
        "--prefix",
        default="page_",
        help='Output filename prefix (default: "page_")',
    )
    parser.add_argument(
        "--engine",
        choices=["auto", "pymupdf", "pdftoppm", "magick"],
        default="auto",
        help="Rendering engine. auto prefers PyMuPDF.",
    )
    parser.add_argument(
        "--jpg-quality",
        type=int,
        default=85,
        help="JPEG quality when using PyMuPDF (default: 85)",
    )
    args = parser.parse_args(argv)

    in_pdf = Path(args.in_pdf).expanduser().resolve()
    if not in_pdf.exists():
        raise FileNotFoundError(str(in_pdf))
    if in_pdf.suffix.lower() != ".pdf":
        raise ValueError("Input must be a .pdf file.")

    out_dir = Path(args.outdir).expanduser().resolve()
    fmt = _normalize_image_format(args.format)
    if args.dpi <= 0:
        raise ValueError("--dpi must be > 0")
    if not (1 <= args.jpg_quality <= 100):
        raise ValueError("--jpg-quality must be in 1..100")

    pages = _parse_pages(args.pages)
    prefix = args.prefix

    engine = args.engine
    if engine == "auto":
        engine = _engine_auto()
    if engine == "none":
        raise RuntimeError(
            "No rendering engine found.\n"
            "- Recommended: pip install pymupdf\n"
            "- Or install Poppler (pdftoppm) / ImageMagick (magick) and ensure it's on PATH."
        )

    if engine == "pymupdf":
        _render_pymupdf(
            in_pdf=in_pdf,
            out_dir=out_dir,
            fmt=fmt,
            dpi=args.dpi,
            jpg_quality=args.jpg_quality,
            pages=pages,
            prefix=prefix,
        )
    elif engine == "pdftoppm":
        _render_pdftoppm(
            in_pdf=in_pdf,
            out_dir=out_dir,
            fmt=fmt,
            dpi=args.dpi,
            pages=pages,
            prefix=prefix,
        )
    elif engine == "magick":
        _render_magick(
            in_pdf=in_pdf,
            out_dir=out_dir,
            fmt=fmt,
            dpi=args.dpi,
            pages=pages,
            prefix=prefix,
        )
    else:
        raise ValueError("Unknown engine: " + str(engine))

    print(str(out_dir))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except Exception as exc:
        print(f"[pdf_to_images.py] ERROR: {exc}", file=sys.stderr)
        raise

