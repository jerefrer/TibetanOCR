#!/bin/sh

cd $( dirname -- "$0"; )

rm -f images/*.txt

google-ocr --client-secret client_secret.json --image-dir images/ --extension .jpg --workers 4 --no-keep

cd images

echo *.txt | xargs cat > output.temp
rm *.txt
mv output.temp output.txt

cd ..
