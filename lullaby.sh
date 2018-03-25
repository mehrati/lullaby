#!/bin/bash

dir_log=$HOME/lullaby/
shut_down=0
declare -a deb_base=("debian" "ubuntu" "mint" "elementary" "kali")
declare -a arch_base=("arch" "antergos" "manjaro")
declare -a fedora_base=("redhat" "fedora" "centos") # TODO add Suport

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
	-t | --time)
		wake_time=$2
		shift
		shift
		;;
	-d | --distro-name)
		distro_name=$2
		shift
		shift
		;;
	-s | --shutdown)
		shut_down=1
		shift
		;;
	-h | --help)
		echo "*** example command ***"
		echo "lullaby -t 'today 11:00' --shutdown"
		echo "lullaby -t 'tomorrow 3:00:22' "
		echo "lullaby -t 'tomorrow 4:00:22' -d distroname"
		exit 0
		shift
		;;
	-v | --version)
		echo "lullaby version 0.0.1"
		exit 0
		shift
		;;
	*)
		# usage
		exit 0
		shift
		;;
	esac
done

if [ -z "$distro_name" ]; then
	if type lsb_release >/dev/null 2>&1; then
		distro_name=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
	else
		echo "please set option -d distribution name"
		exit 1
	fi
fi

for i in "${deb_base[@]}"; do
	if [ $distro_name == $i ]; then
		distro_base="debian"
		break
	fi
done
if [ -z $distro_base ]; then
	for i in "${arch_base[@]}"; do
		if [ $distro_name == $i ]; then
			distro_base="arch"
			break
		fi
	done
fi

if [ ! -z $distro_base ]; then
	if [ -z "$wake_time" ]; then
		echo "please set option -t 'time wake up' "
		exit 1
	else
		echo -n "Root Password :"
		read -s root_pass
		echo ""
		if [ -z "$root_pass" ]; then
			echo "please enter password "
			exit 1
		else
			timestamp=$(date +%s -d "$wake_time")
			echo $root_pass | sudo -S rtcwake -m mem -l -t $timestamp | tee -a $dir_log/data.log
			if [[ $(date +%s -d "today $(date "+%H:%M")") -lt $timestamp ]]; then
				echo $root_pass | sudo -S rtcwake disable -t $timestamp | tee -a $dir_log/data.log
				echo "you stop lullaby process"
				exit 1
			fi
			clear
			echo "####*** Wakeup System At $(date) ***####" >>$dir_log/data.log
		fi
	fi
else
	echo "sorry your os/distribution not supported"
	exit 1
fi

if ! ping google.com -c 3 1>/dev/null 2>&1; then
	# TODO try auto connect to net
fi

if ping google.com -c 3 1>/dev/null 2>&1; then
	if [ $distro_base == "arch" ]; then
		echo $root_pass | sudo -u root --stdin pacman -Sy | tee -a $dir_log/data.log
		echo "####*** Update System At $(date) ***####" >>$dir_log/data.log
		echo "Y" | sudo pacman -Su | tee -a $dir_log/data.log
		echo "####*** Upgrade System At $(date) ***####" >>$dir_log/data.log
	elif [ $distro_base == "debian" ]; then
		echo $root_pass | sudo -u root --stdin sudo apt update | tee -a $dir_log/data.log
		echo "####*** Update System At $(date) ***####" >>$dir_log/data.log
		sudo apt upgrade -y | tee -a $dir_log/data.log
		echo "####*** Upgrade System At $(date) ***####" >>$dir_log/data.log
	fi
else
	echo "####*** System disconnected ***####" >>$dir_log/data.log
fi

if [[ shut_down -eq 1 ]]; then
	echo "system shutdown ..."
	sleep 10
	echo "####*** Shutdown System At $(date) ***####" >>$dir_log/data.log
	shutdown now
fi
