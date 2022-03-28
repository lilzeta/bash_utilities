
#!/bin/bash
# https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019

# echo then execute
e_e () {
	echo "\$: $@" ; "$@" ; 
}
is_num="^[0-9]+$"
is_measure="^[0-9]+*"

# set i & t to first two ints and set args to the rest
indexi_t_args () {
  is_num="^[0-9]+$"
  args=()
  for var in "$@"
  do
    if [[ $var =~ $is_num ]] ; then
      if [[ ! "$i" =~ $is_num ]] ; then
        i="$var"
    elif [[ ! "$t" =~ $is_num ]] ; then
        t="$var"
      else
        args+=("$var")
      fi
    else
      args+=("$var")
    fi
  done
  if ! [[ "$i" =~ $is_num ]] ; then
    i=0
  fi
  if ! [[ "$t" =~ $is_num ]] ; then
    t=999
  fi
}

# from/to ...rest
unset i t args
# pull ints into i/t or 0/999 rest to $args
indexi_t_args "$@"

yes_or_no () {
	if [ $# -ge 3 ] && [ $3 = "invert" ]; then
		q="$1 y/n [n]: "
		def=n
	else
		q="$1 y/n [y]: "
		def=y
	fi	
	while true; do
		read -p "$q" yn
		yn=${yn:-$def}
		case $yn in
			[Yy]*) return 1 ;;
			[Nn]*) 
				echo "$2"
				return 0 ;;
		esac
	done
}
we_good="we good so far^ ?"
error_noc="manually fix or ch script"

[ $i -ge $t ] && exit
if [ $i -eq 0 ]; then
	echo $i
	echo 'ONLY after : "chroot /target"'
	yes_or_no "$we_good" "$error_noc" && exit
	echo "yeah a.ok"
	e_e mount -a
	e_e apt install -y cryptsetup-initramfs
	# This allows the encrypted volumes to be automatically unlocked at boot-time. 
	# The key-file and supporting scripts are added to the /boot/initrd.img-$VERSION files. 
	echo 'echo "KEYFILE_PATTERN=/etc/luks/*.keyfile" > /etc/cryptsetup-initramfs/conf-hook'
	echo "KEYFILE_PATTERN=/etc/luks/*.keyfile" > /etc/cryptsetup-initramfs/conf-hook
	echo 'echo "UMASK=0077" >> /etc/initramfs-tools/initramfs.conf'
	echo "UMASK=0077" >> /etc/initramfs-tools/initramfs.conf
	e_e mkdir /etc/luks
	e_e dd if=/dev/urandom of=/etc/luks/boot_os.keyfile bs=512 count=1
	# 1+0 records in u=rx,go-rwx /etc/luks
	e_e chmod u=rx,go-rwx /etc/luks
	e_e chmod u=r,go-rwx /etc/luks/boot_os.keyfile
	
	yes_or_no "$we_good" "$error_noc" && { echo $i; exit; }
	echo "yeah a.ok"
	((i++))
fi

[ $i -ge $t ] && exit
if [ $i -eq 1 ]; then
	echo $i
	e_e cryptsetup luksAddKey ${dev_p}${_boot} /etc/luks/boot_os.keyfile
	e_e cryptsetup luksAddKey ${dev_p}${_rootf} /etc/luks/boot_os.keyfile
	yes_or_no "$we_good" "$error_noc" && { echo $i; exit; }
	((i++))
fi

[ $i -ge $t ] && exit
if [ $i -eq 2 ]; then
	echo $i
	echo "echo \"LUKSBOOT UUID=$(blkid -s UUID -o value ${dev_p}${_boot}) /etc/luks/boot_os.keyfile luks,discard\" > /etc/crypttab"
	# FYI/heed for error retries this is flashing [>] /etc/crypttab
	echo "LUKSBOOT UUID=$(blkid -s UUID -o value ${dev_p}${_boot}) /etc/luks/boot_os.keyfile luks,discard" > /etc/crypttab
	echo "echo \"${dn}${_rootf}_crypt UUID=$(blkid -s UUID -o value ${dev_p}${_rootf}) /etc/luks/boot_os.keyfile luks,discard\" >> /etc/crypttab"
	echo "${dn}${_rootf}_crypt UUID=$(blkid -s UUID -o value ${dev_p}${_rootf}) /etc/luks/boot_os.keyfile luks,discard" >> /etc/crypttab
	apt-get update
	apt install curl gcc make # bish
	e_e update-initramfs -u -k all	
	yes_or_no "$we_good" "$error_noc" && { echo $i; exit; }
	echo "yeah a.ok"
	((i++))
fi

[ $i -ge $t ] && exit
if [ $i -eq 3 ]; then	
	echo $i
	echo 'basically leaving my use case here as optional but you can do a thish-ish'
	yes_or_no "setup download cuda/nvidia? (if not familar choose [n])" "$error_noc" && { echo "thas it: reboot"; exit; }
	
	cd /
	# update url via: https://developer.nvidia.com/cuda-downloads
	#curl https://us.download.nvidia.com/XFree86/Linux-x86_64/495.46/NVIDIA-Linux-x86_64-495.46.run > 495.46.run
	curl https://developer.download.nvidia.com/compute/cuda/11.3.0/local_installers/cuda_11.3.0_465.19.01_linux.run > /11.3.run
	echo "blacklist nouveau" >> /etc/modprobe.d/blacklist-nouveau.conf
	echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nouveau.conf
	echo "change these two grub lines to the following"
	echo "GRUB_TIMEOUT_STYLE=menu"
	echo "GRUB_TIMEOUT=7"
	yes_or_no "ready for script to open config?" "$error_noc" && { exit; }
	e_e nano /etc/default/grub
	e_e update-grub
	# e_e update-initramfs -u
	echo "after reboot straight into recovery to run:"
	echo "sudo sh /11.3.run"
	echo "thas it: reboot"
	((i++))
fi

rm enc2.sh

