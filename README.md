# PICopy
Yet Another RaspberryPi Tool. The PICopy lets you copy files from an untrusted USB to a trusted one. If you are a journalist working with documents from "untrusted" source, this tool if for you.

We provide here the scripts to build the raspbian image.
## Prepare the raspbian image
Running the script `01_image_prepare.sh` with the following variable download the latest raspbian lite image.
```bash
sh 01_image_prepare.sh
```

## Building the image
Running the script `IMAGE_FILE=./raspbian.img CONFIG_DIR=./picopy sh rpi_02_build.sh` with the following options will install all the necessary libraries for the file copying.

The raspbian image will be modified to be a read only system. At every boot it will read for the USB on the top left port and write on any other USB. During the copy process the system will play in the background a list of midi audio files. When all actions are done, the system will automatically shutdown. In case the provided destination usb can't be mounted, the app will play 4 beeps.

The copy script detect automatically the partition structure on the provided USB. The destination USB must be formatted with FAT16/32/NTFS. In addition, the source USB can be in any of the following file system: ext2 ext3 ext4 hfs hfs+. The following partition tables are also supported: msdos, gpt, loop and mac.

## References
This work was inspired by the [Circlean project](https://github.com/CIRCL/Circlean)
