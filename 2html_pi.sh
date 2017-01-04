#!/bin/sh
set -e
set -x

systemctl set-default multi-user.target

echo "hdmi_force_hotplug=1" >> /boot/config.txt

echo '# /etc/pmount.allow
/dev/sdb1
/dev/sda*' > /etc/pmount.allow

useradd -m 2html
usermod -a -G plugdev 2html
ln -s /tmp/libreoffice /home/2html/libreoffice
ln -s /tmp/tmp_config /home/2html/.config
ln -s /tmp/tmp_cache /home/2html/.cache
chown -R 2html:2html /home/2html/

echo "2html hard priority -40" > /etc/security/limits.d/20-2html.conf
ln -s /proc/mounts /etc/mtab

echo '#!/bin/sh -e
clean(){
    echo "Rc Local done, quit."
    /sbin/shutdown -P -h now
}

/bin/sleep 10

if [ -e /dev/sda ]; then
  if [ -e /dev/sdb ]; then
    /sbin/ifconfig eth0 down
    trap clean EXIT TERM INT
    /bin/sh /opt/2html/init.sh
  fi
fi

exit 0' > /etc/rc.local
chmod +x /etc/rc.local

sed -i 's/ quiet init=.*$//' /boot/cmdline.txt

sed -i 's/^%sudo/#%sudo/' /etc/sudoers
sed -i 's/^root/#root/' /etc/sudoers
sed -i 's/^pi/#pi/' /etc/sudoers

echo 'proc            /proc           proc    defaults          0       0
/dev/mmcblk0p1  /boot           vfat    ro,defaults          0       0
/dev/mmcblk0p2  /               ext4    ro,defaults,noatime  0       0
tmpfs   /media  tmpfs  rw,size=64M,noexec,nodev,nosuid,mode=1777   0  0
tmpfs   /tmp    tmpfs  rw,size=64M,noexec,nodev,nosuid,mode=1777   0  0' > /etc/fstab

dphys-swapfile swapoff
dphys-swapfile uninstall
