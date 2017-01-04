#!/bin/sh
set -e
set -x
MAX_SIZE="4000" # 4M

SYNC='/bin/sync'
MOUNT='/bin/mount'
PMOUNT='/usr/bin/pmount -A -c utf8'
PUMOUNT='/usr/bin/pumount'
SCRIPTS_DIR='/opt/2html'
DEV_SRC='/dev/sda'
DEV_DST='sdb1'
SRC="src"
DST="dst"

clean(){
    ${SYNC}
    pumount ${SRC}
    pumount ${DST}
    exit
}

trap clean EXIT TERM INT

if [ ! -b "/dev/${DEV_DST}" ]; then
echo "Missing destination device at (/dev/${DEV_DST})!"
exit
fi

if ${MOUNT}|grep ${DST}; then
${PUMOUNT} ${DST} || true
fi

${PMOUNT} -w ${DEV_DST} ${DST}
if [ ${?} -ne 0 ]; then
echo "Unable to mount device /dev/${DEV_DST} at /media/${DST}"
exit
fi

if [ ! -b ${DEV_SRC} ]; then
echo "Source device (${DEV_SRC}) does not exists."
exit
fi

SRC_PARTITIONS=`ls "${DEV_SRC}"* | grep "${DEV_SRC}[1-9][0-6]*" || true`
if [ -z "${SRC_PARTITIONS}" ]; then
echo "${DEV_SRC} does not have any partitions."
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
echo "Unable to mount ${partition} on /media/${SRC}"
else
echo "${partition} mounted at /media/${SRC}"
current_time=`date +"%Y.%m.%d.%H.%M.%S"`
target_dir="/media/${DST}/2html_job_${current_time}/dir_${PCOUNT}"
mkdir -p "${target_dir}"
src_size="`du -s /media/${SRC} | awk '{ print $1 }'`"
free_space_dst="`df /media/${DST} | sed 1d | awk '{ print $4 }'`"

if [ "$src_size" -gt "$free_space_dst" ]; then
echo "No more space left in the destination USB drive!" > ${target_dir}/nomorespaceleft.txt
exit
fi

if [ "$src_size" -lt "$MAX_SIZE" ]; then
#copying and converting the files!
/usr/bin/python ${SCRIPTS_DIR}/2html.py /media/${SRC} ${target_dir}
else
#copying a compressed version of the source dir
/usr/local/bin/7z a ${target_dir}/output.zip /media/${SRC}
fi

/usr/bin/python ${SCRIPTS_DIR}/2html.py /media/${SRC} ${target_dir}

fi
PCOUNT=`expr $PCOUNT + 1`
done
