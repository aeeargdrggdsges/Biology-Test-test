#!/usr/bin/env python3
"""Extract text from scanned/photographed PDF pages using PaddleOCR.

Usage:
    python3 extract_pdf_ocr.py <input.pdf> <output_dir> [--dpi 200]

For each PDF, renders every page to a PNG image, runs PaddleOCR on each
image, and writes:
  - ocr_output/images/<pdf_stem>/page_XX.png   (rendered page images)
  - ocr_output/<pdf_stem>.md                   (combined extracted text)
"""
import argparse
import sys
from pathlib import Path

import fitz  # PyMuPDF
from paddleocr import PaddleOCR


def render_pdf_pages(pdf_path: Path, images_dir: Path, dpi: int) -> list[Path]:
    images_dir.mkdir(parents=True, exist_ok=True)
    doc = fitz.open(pdf_path)
    zoom = dpi / 72
    matrix = fitz.Matrix(zoom, zoom)
    page_paths = []
    for i, page in enumerate(doc, start=1):
        pix = page.get_pixmap(matrix=matrix)
        out_path = images_dir / f"page_{i:02d}.png"
        pix.save(out_path)
        page_paths.append(out_path)
    doc.close()
    return page_paths


def run_ocr(ocr: PaddleOCR, image_path: Path) -> str:
    result = ocr.predict(str(image_path))
    lines = []
    for page_result in result:
        texts = page_result.get("rec_texts", [])
        lines.extend(texts)
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("pdf", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--dpi", type=int, default=200)
    args = parser.parse_args()

    stem = args.pdf.stem
    images_dir = args.output_dir / "images" / stem
    md_path = args.output_dir / f"{stem}.md"

    print(f"Rendering pages for {args.pdf.name} at {args.dpi} DPI...")
    page_paths = render_pdf_pages(args.pdf, images_dir, args.dpi)
    print(f"Rendered {len(page_paths)} pages.")

    ocr = PaddleOCR(use_doc_orientation_classify=False,
                     use_doc_unwarping=False,
                     use_textline_orientation=False,
                     enable_mkldnn=False)

    sections = [f"# {stem}\n"]
    for i, img_path in enumerate(page_paths, start=1):
        print(f"OCR page {i}/{len(page_paths)}: {img_path.name}")
        text = run_ocr(ocr, img_path)
        sections.append(f"## Page {i}\n\n{text}\n")

    md_path.parent.mkdir(parents=True, exist_ok=True)
    md_path.write_text("\n".join(sections), encoding="utf-8")
    print(f"Wrote extracted text to {md_path}")


if __name__ == "__main__":
    sys.exit(main())
