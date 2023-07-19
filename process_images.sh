google-ocr --client-secret client_secret.json --image-dir images/ --extension .jpg --workers 4 --no-keep

cd images
cat *.txt > output.temp
rm *.txt
mv output.temp output.txt
cd ..
