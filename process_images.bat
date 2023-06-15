google-ocr --client-secret client_secret.json --image-dir images/ --extension .jpg --workers 4

cd images
copy *.txt output.temp
del *.txt
rename output.temp output.txt
"C:\Program Files\LibreOffice\program\soffice.exe" --convert-to odt output.txt
del output.txt
cd ..