#!/bin/bash
set -e
cd /home/user/Biology-Test-test
for f in source_pdfs/*.pdf; do
    stem=$(basename "$f" .pdf)
    if [ -f "ocr_output/${stem}.md" ]; then
        echo "SKIP (already done): $stem"
        continue
    fi
    echo "=== Processing $stem ==="
    python3 scripts/extract_pdf_ocr.py "$f" ocr_output
done
echo "ALL DONE"
