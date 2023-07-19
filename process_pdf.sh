cd pdf
google-ocr --client-secret client_secret.json --pdf input.pdf --workers 4 --no-keep

cat *.txt > output.txt
rm input*.txt
rm input*.jpg
cd ..
