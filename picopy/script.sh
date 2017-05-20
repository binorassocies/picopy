#!/bin/bash
set -e
BOX_NAME="picopy"
PACKAGES_BASE="pmount ntfs-3g timidity alsa-utils parted"

apt-get -y purge dhcpcd5 isc-dhcp-client ntp bluez openssh-server pi-bluetooth \
  raspi-config openssh-client openssh-sftp-server gcc g++ wget wpasupplicant \
  wireless-tools gdb console-setup firmware-atheros firmware-brcm80211 \
  firmware-libertas firmware-ralink firmware-realtek gdb isc-dhcp-common iw \
  samba-common wireless-tools wireless-regdb vim-common vim-tiny
apt-get -y autoremove

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

apt-get update
apt-get -y upgrade
apt-get -y install $PACKAGES_BASE

systemctl set-default multi-user.target

sed -i 's/XKBLAYOUT="gb"/XKBLAYOUT="us"/g' /etc/default/keyboard
echo 'hdmi_force_hotplug=1' >> /boot/config.txt

echo $BOX_NAME > /etc/hostname

echo '# /etc/pmount.allow
/dev/sda*
/dev/sdb*' > /etc/pmount.allow

useradd -m picopy
usermod -a -G plugdev picopy
usermod -a -G audio picopy

ln -s /proc/mounts /etc/mtab

sed -i 's/ quiet init=.*$//' /boot/cmdline.txt
sed -i "1 s|$| fastboot noswap ro consoleblank=0|" /boot/cmdline.txt

sed -i 's/^%sudo/#%sudo/' /etc/sudoers
sed -i 's/^root/#root/' /etc/sudoers
sed -i 's/^pi/#pi/' /etc/sudoers

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
    /bin/sh /opt/copy/init.sh
  fi
fi

exit 0' > /etc/rc.local
chmod +x /etc/rc.local

rm -Rf /etc/rc*.d/*console-setup*
rm -Rf /etc/rc*.d/*apply_noobs_os_config*
rm -Rf /etc/rc*.d/*resize2fs_once.service*
rm -Rf /etc/rc*.d/*networking*
rm -Rf /etc/rc*.d/*bluetooth*

rm -Rf /etc/init.d/*console-setup*
rm -Rf /etc/init.d/*apply_noobs_os_config*
rm -Rf /etc/init.d/*resize2fs_once.service*
rm -Rf /etc/init.d/*networking*

rm -Rf /etc/systemd/system/multi-user.target.wants/regenerate_ssh_host_keys.service
rm -Rf /etc/systemd/system/multi-user.target.wants/sshswitch.service

echo 'proc            /proc           proc    defaults          0       0
/dev/mmcblk0p1  /boot           vfat    ro,defaults          0       0
/dev/mmcblk0p2  /               ext4    ro,defaults,noatime  0       0
tmpfs   /media  tmpfs  rw,size=64M,noexec,nodev,nosuid,mode=1777   0  0
tmpfs   /tmp    tmpfs  rw,size=64M,noexec,nodev,nosuid,mode=1777   0  0' > /etc/fstab

dphys-swapfile swapoff
dphys-swapfile uninstall

echo "" > /etc/network/interfaces

# Clean up
apt-get clean all
cat /dev/null > ~/.bash_history
