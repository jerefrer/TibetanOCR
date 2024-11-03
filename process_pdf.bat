cd pdf
google-ocr --client-secret ../client_secret.json --pdf input.pdf --workers 4 --no-keep --verbose

copy *.txt output.txt
del input*.txt
del input*.jpg
cd ..