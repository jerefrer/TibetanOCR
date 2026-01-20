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