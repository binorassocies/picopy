SYNC='/bin/sync'

SCRIPTS_DIR='/opt/copy'
USERNAME='picopy'
MUSIC_DIR="/opt/music"

MOUNT='/bin/mount'
PMOUNT='/usr/bin/pmount -A -c utf8'
PUMOUNT='/usr/bin/pumount'

DEV_DST='/dev/dst_usb'
DEV_SRC='/dev/src_usb'

alarm(){
  ( /usr/bin/speaker-test --frequency $1 --test sine )&
  pid=$!
  sleep ${2}s
  kill -9 $pid
}

get_partition_table(){
  pt_type=`/sbin/parted "$1" print | grep "Partition Table" | awk '{print $3}'`

  case "$pt_type" in
    msdos)
      pt_l=`/sbin/parted "$1" print | sed -e '1,/Number/d' | grep -e "[[:space:]]*[[:digit:]]" | awk '{print $1":"$6}'`
      ;;
    gpt|loop|mac)
      pt_l=`/sbin/parted "$1" print | sed -e '1,/Number/d' | grep -e "[[:space:]]*[[:digit:]]" | awk '{print $1":"$5}'`
      ;;
  esac

  for i in $pt_l; do
    fs_i=`echo $i | cut -d ":" -f 1`
    fs_t=`echo $i | cut -d ":" -f 2`
    if [ ! -z "$fs_t" ]; then
      if [ -n "`echo $2 | xargs -n1 echo | grep -e $fs_t`" ]; then
        if [ "$pt_type" = loop ]; then
          echo $1
        else
          echo $1$fs_i
        fi
      fi
    fi
  done
}
