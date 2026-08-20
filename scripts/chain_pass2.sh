#!/bin/bash
# Waits for the pass1 run_all.sh process to finish, renames its outputs to
# the _pass1 naming scheme, then kicks off pass2 at 300 DPI.
set -e
cd /home/user/Biology-Test-test

PASS1_PID="$1"
if [ -z "$PASS1_PID" ]; then
    echo "Usage: chain_pass2.sh <pass1_pid>"
    exit 1
fi

echo "Waiting for pass1 (pid $PASS1_PID) to finish..."
while kill -0 "$PASS1_PID" 2>/dev/null; do
    sleep 30
done
echo "Pass1 finished. Renaming outputs to *_pass1 naming..."

for f in ocr_output/*.md; do
    base=$(basename "$f" .md)
    case "$base" in
        *_pass1|*_pass2|*_pass3) continue ;;
    esac
    mv "$f" "ocr_output/${base}_pass1.md"
    if [ -d "ocr_output/images/${base}" ]; then
        mv "ocr_output/images/${base}" "ocr_output/images/${base}_pass1"
    fi
    echo "Renamed $base -> ${base}_pass1"
done

echo "Starting pass2 at 300 DPI..."
./scripts/run_pass.sh --dpi 300 --tag pass2
echo "PASS2 ALL DONE"
