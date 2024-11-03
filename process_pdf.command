#!/bin/sh

cd $( dirname -- "$0"; )

rm -f pdf/*.txt pdf/*.jpg

cd pdf

google-ocr --client-secret ../client_secret.json --pdf input.pdf --workers 4 --no-keep --verbose

echo *.txt | xargs cat > output.txt
rm input*.txt
rm input*.jpg

cd ..
