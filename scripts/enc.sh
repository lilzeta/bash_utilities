#!/bin/bash
# https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019

echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo 'GUIDE: https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo "user must track logging for errors, script editing is required for non-nvme see link in comments ^"
echo "a good idea is to track bash line by line with the guide"
echo "script is as-root so it's use implies your ability to read and understand basic cmdline scripting "

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

# piecewise progresion like :\$ bash crit 3 4
[ $i -ge $t ] && exit
# checks 
if [ $i -eq 0 ]; then
	echo $i
	echo "if error reply (n) & resume like :\$ bash enc.sh 2"
	echo "or piecewise progresion like :\$ bash crit 3 4"

	echo "first: sudo -i"
	echo "do not use :~# sh"
	echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	message="did you sudo -i before running this script?"
	error_noc="do that"
	yes_or_no "$message" "$error_noc" && exit
	mount | grep efivars
	message="efi gook^ ?"
	error_noc="UEFI boot mode is required "
	yes_or_no "$message" "$error_noc" && exit

	echo $SHELL
	message="bash shell^ ?"
	error_noc="bash is req'd"
	yes_or_no "$message" "$error_noc" && exit

	echo '~~~~ popping gparted ( u snatch nvme<[CNTLR]n[NAME]> ) ~~~'
	gparted & 
	sleep .5 # continue after gparted intro stout spam
	((i++))
fi

[ $i -ge $t ] && exit
if [ $i -eq 1 ]; then
	echo $i
	echo "from /dev/nvme[CNTLR]n[NAME]p[PART] "
	while true; do
		read -p "$* **[input]** [<CNTLR>n<NAME>] i.e. [0n1] : " de
		# default
		de=${de:-0n1}
		case $de in
		    [^\d]*) # if starts with a digit
		    	break;;
		    *) 
		    	echo "input should start with a number "
		esac
	done
	echo "enter first available partition: if win10 installed first likely 5, otherwise likely : 1"
    	while true; do
		read -p "$* **[input]** [1] : " pa
		pa=${pa:-1}
		if [[ pa -eq 1 ]] ; then
			echo "paste the following two lines [enter] then resume with :\$ bash enc.sh 2 "
			# de##*/ means lose the '/dev/' bits
			printf 'export de="/dev/nvme%s"; export dn="${de##*/}"; export dev_p="${de}p"; export dn="${dn}p"; \n' "$de"
			printf 'export _grub=2; export _boot=3; export _rootf=5 \n'
			exit
		elif [[ $pa =~ $is_num ]] ; then
			echo "paste the following two lines [enter] then resume with :\$ bash enc.sh 2 "
			printf 'export de="/dev/nvme%s"; export dn="${de##*/}"; export dev_p="${de}p"; export dn="${dn}p"; \n' "$de"
			printf 'export _grub=%s; export _boot=%s; export _rootf=%s \n' "$pa" $((pa + 1)) $((pa + 3))
			exit
		else 
			echo "input should be a number "
		fi
	done
	exit
fi

echo "Because you have run the export at root you may run any subsection at root vs this subshell. "

# setup logging messages for most the rest
we_good="we good so far^ ?"
error_noc="manually fix or ch script"

[ $i -ge $t ] && exit
if [ $i -eq 2 ]; then
	echo $i
	echo "if EFI exists and you want a fresh partition, delete partition BEFORE continuing"
	echo "remove any partitions you do not want"
	yes_or_no "$we_good" "$error_noc" && { echo $i; exit; }

	newEFI_ka="format EFI?"
	yes_or_no "$newEFI_ka" "moving on." "invert" || {
		echo "~~~~~~~~~~~~~~ create EFI ~~~~~~~~~~~~~~~"
		# use disks to create part table
		e_e sgdisk -n 1:0:+200M -t 1:ef00 -c 1:EFI-SP $de
		e_e mkfs.vfat -F 16 -n EFI-SP ${dev_p}1
	}
	echo "~~~~~~~~~~~~~~ create part\'s ~~~~~~~~~~~~~~~"
	e_e sgdisk -n ${_grub}:0:+6M -t ${_grub}:ef02 -c ${_grub}:/GRUB $de
	e_e sgdisk -n ${_boot}:0:+1G -t 1:8301 -c ${_boot}:/boot $de 
	while true; do
		echo "input root:/ partition size, enter [0] for fill empty space ex: 1T, 500G, mums approximate mass"
		read -p "$* **[input]** [0] : " rewt
		# default
		rewt=${rewt:-0}
		if [[ rewt = 0 ]] ; then
			e_e sgdisk -n ${_rootf}:0:0 -t 1:8301 -c ${_rootf}:/rootf $de # rest of
			break
		elif [[ $pa =~ $is_measure ]] ; then
			e_e sgdisk -n ${_rootf}:0:+1T -t 1:8301 -c ${_rootf}:/rootf $de 
			break
		else 
			echo "input should be a number "
		fi
	done

	e_e sgdisk --hybrid 1:${_grub}:${_boot} $de
	sgdisk --print $de
	yes_or_no "$we_good" "$error_noc" && { echo $i; exit; }
	((i++))
fi

[ $i -ge $t ] && exit
if [ $i -eq 3 ]; then
	echo $i
	echo "~~~~~~~~~~~~ format/crypt part\'s ~~~~~~~~~~~~~~"
	e_e cryptsetup luksFormat --type=luks1 ${dev_p}${_boot}
	e_e cryptsetup luksFormat ${dev_p}${_rootf}
	
	yes_or_no "$we_good" "$error_noc" && { echo $i; exit; }
	echo "yeah a.ok"
	((i++))
fi

[ $i -ge $t ] && exit
if [ $i -eq 4 ]; then
	echo "~~~~~~~~~~~~~~ unlock part\'s ~~~~~~~~~~~~~~~~~"
	e_e cryptsetup open ${dev_p}${_boot} LUKSBOOT
	e_e cryptsetup open ${dev_p}${_rootf} ${dn}${_rootf}_crypt
	ls /dev/mapper/

	yes_or_no "$we_good" "$error_noc" && { echo $i; exit; }
	echo "yeah a.ok"
	((i++))
fi

[ $i -ge $t ] && exit
if [ $i -eq 5 ]; then
	echo $i
	echo "~~~~~~~~~~~~ format /boot part ~~~~~~~~~~~~~~"
	echo mkfs.ext4 -L boot /dev/mapper/LUKSBOOT
	mkfs.ext4 -L boot /dev/mapper/LUKSBOOT
	yes_or_no "$we_good" "$error_noc" && { echo $i; exit; }
	echo "yeah a.ok"
	((i++))
fi

# next two purpose is a bit unclear check guide
# i think this allows single password entry?
[ $i -ge $t ] && exit
if [ $i -eq 6 ]; then
	echo $i
	echo "~~~~~~~~~ create part vol groups ~~~~~~~~~"
	e_e pvcreate /dev/mapper/${dn}${_rootf}_crypt
	e_e vgcreate ubuntu-vg /dev/mapper/${dn}${_rootf}_crypt
	yes_or_no "$we_good" "$error_noc" && { echo $i; exit; }
	echo "yeah a.ok"
	((i++))
fi

[ $i -ge $t ] && exit
if [ $i -eq 7 ]; then
	echo $i
	echo "~~~~~~~~~ create log vol groups ~~~~~~~~~~~"
	echo lvcreate -L 64G -n swap_1 ubuntu-vg
	lvcreate -L 64G -n swap_1 ubuntu-vg
	echo lvcreate -l 90%FREE -n root ubuntu-vg
	lvcreate -l 90%FREE -n root ubuntu-vg
	yes_or_no "$we_good" "$error_noc" && { echo $i; exit; }
	echo "yeah a.ok"
	((i++))
fi

[ $i -ge $t ] && exit
if [ $i -eq 8 ]; then
	echo $i
	echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	echo '1. start install following the guide: https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019 & *immediately* => '
	echo '2. As soon as you have completed the forms (and the progress bars start)...'
	echo 'switch to the Terminal to paste following command which configures GRUB.'
	echo 'These commands wait until the installer has created the GRUB directories and then adds a drop-in file telling'
	echo 'GRUB to use an encrypted file-system. The command will not return to the shell prompt until the target directory' 
	echo 'has been created by the installer. In most cases that will have been done before this command is executed so it should instantly return.'
	echo 'the command in 2.) follows: '
	echo '~~~~~~~~~~~~~~~^^^~~~~~~~~~~~~~~~'
	echo 'while [ ! -d /target/etc/default/grub.d ]; do sleep 1; done; echo "GRUB_ENABLE_CRYPTODISK=y" > /target/etc/default/grub.d/local.cfg'
	echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	echo 'read 1. & 2. BEFORE continuing'
	echo " & don't forget to PASTE ~.~' "
	echo 'after install continue with :\$ bash enc.sh 9'
	echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	exit
fi

yes_or_no "have all steps completed ^ & also waited for installation to complete?" "_" && { echo $i; exit; }
[ $i -ge $t ] && exit
if [ $i -eq 9 ]; then
	echo $i
	echo '~~~~~~~~~mount/bind root~~~~~~~~~~~~~~~~'
	e_e mount /dev/mapper/ubuntu--vg-root /target
	echo 'for n in proc sys dev etc/resolv.conf; do mount --rbind /$n /target/$n; done'
	for n in proc sys dev etc/resolv.conf; do mount --rbind /$n /target/$n; done
	yes_or_no "${we_good}" "ay" && { echo $i; exit; }
	((i++))
fi


[ $i -ge $t ] && exit
if [ $i -eq 10 ]; then
	echo $i
	echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	echo 'paste the following command:'
	echo 'chroot /target'
	echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	echo "after we need to migrate script 2 onto target"
	echo "i don't rec. copy/paste whole file into shell as non happy path will exit root shell."
	echo "touch enc2.sh; nano enc2.sh"
	echo "paste enc2.sh, save, exit ctrl-s ->  ctrl-x "
	echo ":~# bash enc2.sh "
fi

rm enc.sh
