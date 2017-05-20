#!/bin/bash
set -e

. /opt/copy/conf.sh

DEV_DST_FS="fat16 fat32 ntfs"
DEV_SRC_FS="$DEV_DST_FS ext2 ext3 ext4 hfs hfs+"

clean(){
    ${SYNC}
}

trap clean EXIT TERM INT

if [ ! -b "${DEV_DST}" ]; then
  echo "Missing destination device at (${DEV_DST})!"
  alarm 1000 1
  alarm 1000 1
  alarm 1000 1
  alarm 1000 1
  exit
fi

DST_PT_L=`get_partition_table $DEV_DST "${DEV_DST_FS}"`
DST_PT=`echo $DST_PT_L | awk '{ print $1 }'`

if [ ! -b ${DEV_SRC} ]; then
  echo "Source device (${DEV_SRC}) does not exists."
  alarm 1000 1
  alarm 1000 1
  exit
fi

SRC_PT=`get_partition_table $DEV_SRC "${DEV_SRC_FS}"`

su ${USERNAME} -c \
  "DEV_DST_PT=$DST_PT SRC_PARTITIONS=\"$SRC_PT\" /bin/sh $SCRIPTS_DIR/picopy.sh"
