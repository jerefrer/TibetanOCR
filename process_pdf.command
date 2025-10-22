#!/bin/sh

cd $( dirname -- "$0"; )

cd pdf

# Function to resize images that exceed 10MB
resize_daemon() {
  local max_size=10485760  # 10MB in bytes
  
  while true; do
    # Find all jpg files larger than 10MB
    for img in *.jpg; do
      [ -e "$img" ] || continue
      
      file_size=$(stat -f%z "$img" 2>/dev/null || echo 0)
      
      if [ "$file_size" -gt "$max_size" ]; then
        echo "🔧 Resizing large image: $img ($(echo "scale=2; $file_size/1048576" | bc)MB)"
        
        # Calculate resize percentage to get under 10MB (with some margin)
        target_size=9437184  # 9MB target to have margin
        scale=$(echo "scale=4; sqrt($target_size/$file_size)" | bc)
        percentage=$(echo "scale=0; $scale * 100" | bc)
        
        # Get current dimensions
        width=$(sips -g pixelWidth "$img" | tail -1 | awk '{print $2}')
        new_width=$(echo "scale=0; $width * $scale" | bc | awk '{print int($1)}')
        
        # Resize using sips (built-in macOS tool)
        sips -Z "$new_width" "$img" --out "$img" > /dev/null 2>&1
        
        echo "✓ Resized $img to $(stat -f%z "$img" | awk '{printf "%.2fMB", $1/1048576}')"
      fi
    done
    
    sleep 2  # Check every 2 seconds
  done
}

# Process each PDF file in the folder
for pdf_file in *.pdf; do
  # Skip if no PDF files found
  [ -e "$pdf_file" ] || continue
  
  # Get the base name without extension
  base_name="${pdf_file%.pdf}"
  
  echo "⚙️ Processing: $pdf_file"
  
  # Start the resize daemon in background
  resize_daemon &
  daemon_pid=$!
  
  # Run OCR with the original filename
  google-ocr --client-secret ../client_secret.json --pdf "$pdf_file" --workers 8 --no-keep --verbose
  
  # Stop the resize daemon
  kill $daemon_pid 2>/dev/null
  wait $daemon_pid 2>/dev/null
  
  # Combine all text files from this PDF into a single output file
  cat "${base_name}".*.txt > "${base_name}.txt" 2>/dev/null
  
  # Clean up temporary files for this PDF
  rm -f "${base_name}".*.txt "${base_name}".*.jpg
  
  echo "✅ Created: ${base_name}.txt"
  echo ""
done

cd ..
