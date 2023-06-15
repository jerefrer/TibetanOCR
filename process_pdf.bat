cd pdf
google-ocr --client-secret client_secret.json --pdf input.pdf --workers 4

copy *.txt output.txt
del input*.txt
del input*.jpg
"C:\Program Files\LibreOffice\program\soffice.exe" --convert-to odt output.txt
del output.txt
cd ..