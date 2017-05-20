#!/bin/sh
set -e

. /opt/copy/conf.sh

SRC="src"
DST="dst"

clean(){
    ${SYNC}
    pumount ${SRC}
    pumount ${DST}
    kill -9 $(cat /tmp/music.pid)
    rm -f /tmp/music.pid
    exit
}

trap clean EXIT TERM INT

if ${MOUNT} | grep ${DST}; then
  ${PUMOUNT} ${DST} || true
fi

${PMOUNT} -w "${DEV_DST_PT}" ${DST}
if [ ${?} -ne 0 ]; then
  echo "Unable to mount device ${DEV_DST_PT} at /media/${DST}"
  alarm 1000 1
  alarm 1000 1
  alarm 1000 1
  exit
fi

/bin/sh $MUSIC_DIR/music.sh &
echo $! > /tmp/music.pid

mkdir -p /media/${DST}/picopy_log/

if [ -z "${SRC_PARTITIONS}" ]; then
  current_time=`date +"%Y.%m.%d.%H.%M.%S"`
  echo "${DEV_SRC} does not have any supported partitions." >> /media/${DST}/picopy_log/${current_time}.txt
  exit
fi

PCOUNT=1
for partition in ${SRC_PARTITIONS}
do
  if [ `${MOUNT} | grep -c ${SRC}` -ne 0 ]; then
    ${PUMOUNT} ${SRC}
  fi

  ${PMOUNT} -r ${partition} ${SRC}
  if [ ${?} -ne 0 ]; then
    current_time=`date +"%Y.%m.%d.%H.%M.%S"`
    echo "Unable to mount ${partition} on /media/${SRC}" >> /media/${DST}/picopy_log/${current_time}.txt
  else
    echo "${partition} mounted at /media/${SRC}"
    current_time=`date +"%Y.%m.%d.%H.%M.%S"`
    target_dir="/media/${DST}/picopy_part_${PCOUNT}"
    mkdir -p "${target_dir}"
    src_size="`du -s /media/${SRC} | awk '{ print $1 }'`"
    free_space_dst="`df /media/${DST} | sed 1d | awk '{ print $4 }'`"

    if [ "$src_size" -gt "$free_space_dst" ]; then
      echo "No more space left in the destination USB drive!" > ${target_dir}/nomorespaceleft.txt
      exit
    fi

    if [ -e ${target_dir}/output.tar.gz ]; then
      c=1
      for ff in ${target_dir}/output*.tar.gz; do
        o_name=${target_dir}/output.$c.tar.gz
        if [ ! -e $o_name ]; then
          break
        else
          c=`expr $c + 1`
        fi
      done
      /bin/tar -zcvf ${target_dir}/output.$c.tar.gz /media/${SRC}
    else
      /bin/tar -zcvf ${target_dir}/output.tar.gz /media/${SRC}
    fi

  fi
  PCOUNT=`expr $PCOUNT + 1`
done
