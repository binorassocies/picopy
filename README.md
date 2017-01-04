# PICopy
Yet Another RaspberryPi Tool. The PICopy lets you copy files from an untrusted USB to a trusted one. If you are a journalist working with documents from "untrusted" source, this tool if for you.

If the size if the files in the source USB is smaller than a predefined threshold (by default 1M) all the documents(.doc, .docx, .ppt, .pdf, .png, .jpeg...) in the source USB will be converted to html using the amazing [PDF2HTMLEX](https://github.com/coolwanglu/pdf2htmlEX) library.

We provide here the scripts to build the raspbian image. The installation scripts of the conversion libraries can be installed on any Debian based system. A build for VM/Docker image with a web app to do the conversion is in the pipeline.
## Prepare the raspbian image
Running the script `01_image_prepare.sh` with the following variable download the latest raspbian lite image and increase its size with 1GB.
```bash
IMAGE_SIZE=1 sh 01_image_prepare.sh
```
This is necessary so the image can accommodate the installation of the extra packages and libraries.

## Building the image
Running the script `02_image_build.sh` with the following options will install all the necessary libraries for the file copying and conversion.
```bash
INSIDE_CHROOT_FILES=files sh 02_image_build.sh
INSIDE_CHROOT_SCRIPT=2html_libs_install.sh sh 02_image_build.sh
INSIDE_CHROOT_SCRIPT=2html_pi.sh sh 02_image_build.sh
```
The raspbian image will be modified to be a read only system. At every boot it will read for the USB on the top left port and write on any other USB. During the conversion/copy process the system will play in the background a list of midi audio files. When all actions are done, the system will automatically shutdown.

## TODO
* Provide a ready to use image file
* Provide a ready to use Virtual Machine to convert large files

## References
This work was inspired by the [Circlean project](https://github.com/CIRCL/Circlean)

[PDF2HTMLEX](https://github.com/coolwanglu/pdf2htmlEX)
