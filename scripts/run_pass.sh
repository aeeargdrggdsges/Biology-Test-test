#!/bin/bash
# Run OCR extraction over all source PDFs with a given DPI and output-file tag.
# Usage: run_pass.sh --dpi N --tag TAG
set -e
cd /home/user/Biology-Test-test

DPI=200
TAG=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dpi) DPI="$2"; shift 2 ;;
        --tag) TAG="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

if [ -z "$TAG" ]; then
    echo "Must pass --tag"
    exit 1
fi

for f in source_pdfs/*.pdf; do
    stem=$(basename "$f" .pdf)
    out_name="${stem}_${TAG}"
    if [ -f "ocr_output/${out_name}.md" ]; then
        echo "SKIP (already done): $out_name"
        continue
    fi
    echo "=== Processing $out_name (dpi=$DPI) ==="
    python3 scripts/extract_pdf_ocr.py "$f" ocr_output --dpi "$DPI" --tag "$TAG"
done
echo "ALL DONE"
