# Installation

Before you can use this tool you will need to have 3 things installed:
- python
- the `poppler` package for python
- the `google-ocr` package for python

You'd also need to have the path to the `google-ocr` binary included in your
system PATH variable so that it can be called from a command line from any
directory.

## Windows

TODO

## Mac / Linux

1) Install macport with the dmg from their website (https://www.macports.org/install.php)
2) Open a terminal (Spotlight search « term »), then type:
   `sudo port install python311 poppler`
   Type your password when asked.
   Wait for all the tools to be downloaded and installed, this can take
   some time and might use around 1Go of drive space.
   Then type in the terminal:
   ```
     python3 -m ensurepip --upgrade
     pip install google-drive-ocr
     echo 'export PATH="/opt/local/Library/Frameworks/Python.framework/Versions/3.11/bin:$PATH"' >> ~/.profile
     echo 'export PATH="/Users/'$USER'/Library/Python/3.11/bin:$PATH"' >> ~/.profile
   ```
3) There is one last step to go through on your first use.
   Follow the instructions for either images or pdf below, and after running
   the corresponding script, refer to the [First use](#first-use) section below to know
   what to do.

# Usage

## Processing images

1. Put all your images as .jpg files in the `images` folder.
2. Click on the file appropriate to your system:
   1. On Mac/Linux: `process_images.command`
   2. On Windows: `process_images.bat`
3. Wait until the script finishes
4. Enter the `images` folder
5. Open the `output.odt` file

/!\ Remember to make a copy of `output.odt` or move it somewhere else because
    it will be overriden the next time you use this tool!


## Processing a PDF

1) Copy your PDF in the `pdf` folder and rename your PDF as `input.pdf`.
2. Click on the file appropriate to your system:
   1. On Mac/Linux: `process_pdf.command`
   2. On Windows: `process_pdf.bat`
3) Enter the `pdf` folder
4) Open the `output.odt` file

/!\ The process will generate a lot of temporary files in the `pdf` folder so
    don't panic, just wait, the temporary files will be cleaned up at the end.
/!\ Remember to make a copy of `output.odt` or move it somewhere else because
    it will be overriden the next time you use this tool!


## First use

When running one of the the two scripts for the first time, your web browser
will be opened and will ask you to login to one of your Google accounts.
This is totally normal since it needs to have permission to access your Google
Drive to perform the OCR. So when asked just select the Google account of your
choice, type your password if you're not already logged in, and validate.

It will then show you a warning saying that Google did not validate this
application. This is also normal since we are using some kind of Google
developers tools without wanting to register an actual application. So just
click the gray link somewhere (on the bottom left in Chrome) that says
something like « Advanced settings », and then on « Access TibetanOCR ».

You will then see a message saying that everything worked and that you can now
close the web page.

Coming back to the terminal you will see that the OCR process is now underway
or already finished. Go to your `images/` or `pdf/` directory to find the
`output.txt` file with the OCRed text.
