#!/bin/sh

# ANSI color codes
BOLD="\033[1m"
RESET="\033[0m"
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
BG_BLACK="\033[40m"
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"
BG_BLUE="\033[44m"
BG_MAGENTA="\033[45m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"

# Function to print section headers
print_header() {
  echo "\n$BOLD$BG_CYAN$WHITE ===== $1 ===== $RESET"
  echo "$CYAN==========================================$RESET"
}

# Function to print success messages
print_success() {
  echo "$BOLD$BG_GREEN$WHITE SUCCESS $RESET $GREEN$BOLD$1$RESET"
}

# Function to print info messages
print_info() {
  echo "$BLUE$BOLD--> $1$RESET"
}

# Function to print warning messages
print_warning() {
  echo "$YELLOW$BOLD/!\ $1$RESET"
}

# Function to print error messages
print_error() {
  echo "$BG_RED$WHITE ERROR $RESET $RED$BOLD$1$RESET"
}

# Function to print highlighted values
print_value() {
  echo "$MAGENTA$BOLD$1$RESET"
}

# Function to count files of a specific type
count_files() {
  find . -maxdepth 1 -name "$1" -type f | wc -l | tr -d ' '
}

cd $( dirname -- "$0"; )

print_header "Tibetan OCR Processing"
print_info "Starting process at $(date +"%H:%M:%S")"

# Remove any existing text files
print_info "Cleaning up any previous text files"
rm -f images/*.txt

# Convert all images to jpg format
print_header "Converting Images to JPG Format"

# Count original images in the images folder (excluding .gitignore and other non-image files)
total_images=$(find images -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.tiff" -o -name "*.bmp" \) | wc -l | tr -d ' ')

if [ "$total_images" -eq 0 ]; then
  print_warning "No image files found in the images folder"
else
  print_info "Found $BOLD$MAGENTA$total_images$RESET$BLUE image(s) to process$RESET"
fi

converted=0
cd images
echo "$CYAN--- Scanning directory: $BOLD$(pwd)$RESET $CYAN---$RESET"

for img in *; do
  # Skip if it's not a file or already has .jpg extension
  if [ -f "$img" ] && [ "${img##*.}" != "jpg" ]; then
    ext="${img##*.}"
    print_info "Converting: $YELLOW$img$RESET $BOLD$GREEN==>$RESET $CYAN${img%.*}.jpg$RESET"
    echo "   $BOLD$BG_BLACK$WHITE Format:$RESET $ext $BOLD$GREEN===>$RESET jpg"
    # Get the base name without extension
    base_name="${img%.*}"
    # Convert to jpg using sips (built-in on macOS)
    sips -s format jpeg "$img" --out "${base_name}.jpg" >/dev/null 2>&1
    # Remove the original file
    rm "$img"
    converted=$((converted+1))
  fi
done

if [ $converted -eq 0 ]; then
  if [ "$total_images" -eq 0 ]; then
    print_warning "No images to convert"
  else
    print_info "No images needed conversion - all files already in $BOLD.jpg$RESET format"
  fi
else
  print_success "Converted $BOLD$MAGENTA$converted$RESET$GREEN image(s) to JPG format$RESET"
fi

# Count jpg files (only actual images)
jpg_count=$(find . -maxdepth 1 -type f -name "*.jpg" | wc -l | tr -d ' ')
if [ "$jpg_count" -eq 0 ]; then
  print_error "No JPG images found to process!"
else
  print_success "Ready to process $BOLD$MAGENTA$jpg_count$RESET$GREEN JPG image(s)$RESET"
fi

# Go back to parent directory
cd ..

# Run OCR on the images
print_header "Running OCR on Images"
print_info "This may take some time depending on the number of images"
echo "$YELLOW$BOLD[TIME]$RESET $CYAN Starting OCR process...$RESET"

google-ocr --client-secret client_secret.json --image-dir images/ --extension .jpg --workers 4 --no-keep

# Process the output files
print_header "Processing OCR Results"
cd images

# Count text files
txt_count=$(count_files "*.txt")
if [ "$txt_count" -eq 0 ]; then
  print_error "No OCR text files were generated!"
  print_warning "Check if the OCR process completed successfully"
else
  print_info "Found $BOLD$MAGENTA$txt_count$RESET$BLUE text file(s) to combine$RESET"
  
  # Fix the xargs command to handle spaces in filenames
  print_info "Combining all text files into a single output"
  echo "$CYAN--- Processing files $CYAN---$RESET"
  find . -name "*.txt" -type f -print0 | xargs -0 cat > output.temp
  rm *.txt
  mv output.temp output.txt
  
  filesize=$(du -h output.txt | cut -f1)
  print_success "OCR processing complete"
  print_info "Output saved to: $BOLD$CYAN$(pwd)/output.txt$RESET"
  print_info "Output file size: $BOLD$MAGENTA$filesize$RESET"
  
  # Convert to Word document with specified font
  print_header "Converting to Word Document"
  print_info "Setting font to TibetanChogyalUnicode-170221 size 32"
  
  # Create a Python script to generate the Word document with proper formatting
  print_info "Creating Python script for Word document generation..."
  cat > create_word_doc.py << 'EOL'
#!/usr/bin/env python3
import sys
from docx import Document
from docx.shared import Pt

# Check if python-docx is installed
try:
    from docx import Document
except ImportError:
    print("Error: python-docx library not installed.")
    print("Please install it with: pip install python-docx")
    sys.exit(1)

# Get input and output file paths from arguments
if len(sys.argv) < 3:
    print("Usage: python create_word_doc.py input.txt output.docx")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

# Read the text content
try:
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
except Exception as e:
    print(f"Error reading input file: {e}")
    sys.exit(1)

# Create a new Word document
doc = Document()

# Set the font and size for the entire document
style = doc.styles['Normal']
style.font.name = "TibetanChogyalUnicode-170221"
style.font.size = Pt(32)

# Add the content
paragraphs = content.split('\n')
for para in paragraphs:
    if para.strip():
        p = doc.add_paragraph(para)
        # Apply the font to each run in the paragraph to ensure it's applied
        for run in p.runs:
            run.font.name = "TibetanChogyalUnicode-170221"
            run.font.size = Pt(32)

# Save the document
try:
    doc.save(output_file)
    print(f"Successfully created Word document: {output_file}")
except Exception as e:
    print(f"Error saving Word document: {e}")
    sys.exit(1)
EOL

  # Make the script executable
  chmod +x create_word_doc.py
  
  # Check if python-docx is installed, install if needed
  print_info "Checking for required Python libraries..."
  if ! python3 -c "import docx" 2>/dev/null; then
    print_warning "The python-docx library is not installed. Attempting to install it..."
    if pip3 install python-docx --user 2>/dev/null; then
      print_success "Successfully installed python-docx"
    else
      print_error "Failed to install python-docx. You may need to install it manually."
      print_info "Run: pip3 install python-docx --user"
      rm -f create_word_doc.py
      return
    fi
  fi
  
  # Run the Python script to create the Word document
  print_info "Generating Word document with Python..."
  if python3 create_word_doc.py output.txt output.docx; then
    print_success "Word document created successfully with proper Tibetan font"
    docx_filesize=$(du -h output.docx | cut -f1)
    print_info "Word document saved to: $BOLD$CYAN$(pwd)/output.docx$RESET"
    print_info "Word document size: $BOLD$MAGENTA$docx_filesize$RESET"
  else
    print_error "Failed to create Word document with Python"
    print_info "You may need to manually convert the text file"
  fi
  
  # Clean up temporary files
  rm -f create_word_doc.py
fi

cd ..

print_header "Process Complete"
print_success "Finished at $BOLD$YELLOW$(date +"%H:%M:%S")$RESET"
print_info "You can find the OCR results in the $BOLD$CYAN$(pwd)/images$RESET folder"

# Calculate and display elapsed time if possible
if [ -n "$SECONDS" ]; then
  elapsed=$SECONDS
  echo "$YELLOW$BOLD[TIME]$RESET $CYAN Total processing time: $BOLD$MAGENTA$(($elapsed / 60))m $(($elapsed % 60))s$RESET"
fi

# Add a pause at the end to prevent the window from closing automatically
echo "\n$BOLD$BG_GREEN$WHITE Press any key to close this window... $RESET"
read -n 1 -s
