#!/bin/sh
set -e

MUSIC="/opt/music/"
TIMIDITY="/usr/bin/timidity"

clean(){
    echo 'Music play ended!'
}

trap clean EXIT TERM INT

amixer cset numid=3 1

files=${MUSIC}*.mid

while true; do
for x in $files
do
$TIMIDITY $x
done
done
