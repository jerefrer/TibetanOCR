google-ocr --client-secret client_secret.json --image-dir images/ --extension .jpg --workers 4 --no-keep

cd images
copy *.txt output.temp
del *.txt
rename output.temp output.txt
cd ..