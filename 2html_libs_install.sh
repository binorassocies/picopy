#!/bin/sh
set -e
set -x

PACKAGES_LIST="wget git cmake pkg-config libgetopt++-dev libspiro-dev python-dev python-pip m4 automake autoconf libtool poppler-data poppler-utils poppler-dbg libpoppler-dev libpoppler-private-dev libjpeg-dev libfontconfig1-dev libfontforge-dev libopenjpeg-dev libpango1.0-dev libglib2.0-dev libxml2-dev giflib-dbg uthash-dev packaging-dev libtiff-dev build-essential flex bison unifont fonts-liberation libreoffice libfontforge1 timidity freepats pmount gnulib ntfs-3g unoconv python-pip ghostscript ttf-liberation"
P7ZIP_VER="16.02"
P7ZIP_SRC="http://downloads.sourceforge.net/project/p7zip/p7zip/$P7ZIP_VER/p7zip_`echo $P7ZIP_VER`_src_all.tar.bz2"
PDF2HTMLEX_VER="0.14.6"
PDF2HTMLEX_SRC="https://github.com/coolwanglu/pdf2htmlEX/archive/v$PDF2HTMLEX_VER.tar.gz"
POPPLER_VER="0.47.0"
POPPLER_SRC="https://poppler.freedesktop.org/poppler-$POPPLER_VER.tar.xz"
FONTFORGE_VER="20160404"
FONTFORGE_SRC="https://github.com/fontforge/fontforge/releases/download/20160404/fontforge-$FONTFORGE_VER.tar.gz"

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

apt-get update
apt-get -y upgrade
apt-get autoremove
apt-get -y install $PACKAGES_LIST
pip install twiggy python-magic

cd /tmp
echo "Downloading p7zip"
wget $P7ZIP_SRC -O p7zip.tar.gz

echo "Installing p7zip #############"
tar -xvf p7zip.tar.gz
cd p7zip_*
make all3
make install
cd ..

echo "Downloading fontforge"
wget $FONTFORGE_SRC -O fontforge.tar.gz

echo "Downloading poppler"
wget $POPPLER_SRC -O poppler.tar.xz

echo "Dowloading pdf2htmlEX"
wget $PDF2HTMLEX_SRC -O pdf2htmlEX.tar.gz

echo "Installing poppler #############"
tar -xvf poppler.tar.xz
cd poppler-*
./configure --enable-xpdf-headers
make
make install
cd ..

echo "Installing fontforge #############"
tar -xzvf fontforge.tar.gz
cd fontforge-*
./bootstrap
./configure
make
make install
ldconfig
cd ..

echo "Installing pdf2htmlEX #############"
tar -xzvf pdf2htmlEX.tar.gz
cd pdf2htmlEX-*
cmake .
make
make install
cd ..

echo "Cleanup ..."
rm -Rf pdf2htmlEX* fontforge* poppler* p7zip_*

apt-get remove isc-dhcp-common
apt-get remove isc-dhcp-client

apt-get clean all
