#!/bin/sh

cd $( dirname -- "$0"; )

cd pdf

# Process each PDF file in the folder
for pdf_file in *.pdf; do
  # Skip if no PDF files found
  [ -e "$pdf_file" ] || continue
  
  # Get the base name without extension
  base_name="${pdf_file%.pdf}"
  
  echo "⚙️ Processing: $pdf_file"
  
  # Run OCR with the original filename
  google-ocr --client-secret ../client_secret.json --pdf "$pdf_file" --workers 8 --no-keep --verbose
  
  # Combine all text files from this PDF into a single output file
  cat "${base_name}".*.txt > "${base_name}.txt" 2>/dev/null
  
  # Clean up temporary files for this PDF
  rm -f "${base_name}".*.txt "${base_name}".*.jpg
  
  echo "✅ Created: ${base_name}.txt"
  echo ""
done

cd ..
