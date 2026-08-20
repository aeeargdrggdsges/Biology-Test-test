# Biology Test

OCR extraction pipeline for the ICSE Class 10 Biology textbook chapter PDFs
(scanned/phone-photographed pages) using [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR).

## Layout

- `source_pdfs/` — original chapter PDFs.
- `scripts/extract_pdf_ocr.py` — renders each PDF page to an image (via
  PyMuPDF) and runs PaddleOCR on it.
- `scripts/run_all.sh` — runs extraction over every PDF in `source_pdfs/`,
  skipping chapters already processed.
- `ocr_output/<chapter>.md` — extracted text per chapter, one section per page.
- `ocr_output/images/<chapter>/page_XX.png` — rendered page images (not
  committed; regenerate locally with the scripts above).

## Usage

```bash
pip install -r requirements.txt
python3 scripts/extract_pdf_ocr.py source_pdfs/ChXX_Name.pdf ocr_output
# or, for every chapter:
./scripts/run_all.sh
```

## Notes

- Models used: PaddleOCR PP-OCRv6 "medium" detection + recognition (full
  accuracy, no `mkldnn` acceleration — this environment's paddlepaddle build
  hits a CPU oneDNN/PIR bug on the text-detection model). On a machine with a
  working `mkldnn` build or a GPU (`paddlepaddle-gpu`), extraction is
  significantly faster with the same models.
- OCR output is raw line-by-line text per page; it is not proofread and may
  contain recognition errors, especially for diagrams/labels.
