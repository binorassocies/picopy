#!/bin/bash
set -e
set -x

SYNC='/bin/sync'
SCRIPTS_DIR='/opt/2html'
USERNAME='2html'
MUSIC_DIR="/opt/music/"

clean(){
    echo Done, cleaning.
    ${SYNC}
    kill -9 $(cat /tmp/music.pid)
    rm -f /tmp/music.pid
}

trap clean EXIT TERM INT

/bin/sh $MUSIC_DIR/music.sh &
echo $! > /tmp/music.pid

mkdir -p /tmp/libreoffice
chown -R ${USERNAME}:${USERNAME} /tmp/libreoffice

mkdir -p /tmp/tmp_config
chown -R ${USERNAME}:${USERNAME} /tmp/tmp_config

mkdir -p /tmp/tmp_cache
chown -R ${USERNAME}:${USERNAME} /tmp/tmp_cache
su ${USERNAME} -c "/bin/sh $SCRIPTS_DIR/2html.sh"
