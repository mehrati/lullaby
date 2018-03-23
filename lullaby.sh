#!/bin/bash
root_pass=""
wake_time=""
distro_name=""
distro_base=""
dir_log=$HOME/lullaby/
shut_down=0
declare -a deb_base=("debian" "ubuntu" "mint" "elementary" "kali")
declare -a arch_base=("arch" "antergos" "manjaro")

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
	-t | --time)
		wake_time=$2
		shift
		shift
		;;
	-p | --root-password)
		root_pass=$2
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
		echo "lullaby -t 'today 11:00' -p password --shutdown"
		echo "lullaby -t 'tomorrow 1:00:22' -p password "
		echo "lullaby -t 'tomorrow 1:00:22' -p password -d distroname"
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
function check_distro() {
	for i in "${deb_base[@]}"; do
		if [ $distro_name == $i ]; then
			distro_base="debian"
			return 1
		fi
	done
	for i in "${arch_base[@]}"; do
		if [ $distro_name == $i ]; then
			distro_base="arch"
			return 1
		fi
	done
	echo "sorry your os/distribution not supported"
	return 0
}

check_distro
if [ $? == 1 ]; then
	if [ -z "$wake_time" ]; then
		echo "please set option -t 'time wake up' "
		exit 1
	else
		if [ -z "$root_pass" ]; then
			echo "please set option -p 'root password' "
			exit 1
		else
			timestamp=$(date +%s -d "$wake_time")
			echo $root_pass | sudo -S rtcwake -m mem -l -t $timestamp >> $dir_log/data.log
			date >> $dir_log/data.log
			echo "** wake up system **" >> $dir_log/data.log
		fi
	fi
fi

if [ $distro_base == "arch" ]; then
	echo $root_pass | sudo -u root --stdin pacman -Sy
	date >> $dir_log/data.log
	echo "** update system **" >> $dir_log/data.log
	echo "Y" | sudo pacman -Su
	date >> $dir_log/data.log
	echo "** upgrade system **" >> $dir_log/data.log
elif [ $distro_base == "debian" ]; then
	echo $root_pass | sudo -u root --stdin sudo apt update
	date >> $dir_log/data.log
	echo "** update system **" >> $dir_log/data.log
	sudo apt upgrade -y
	date >> $dir_log/data.log
	echo "** upgrade system **" >> $dir_log/data.log
fi

if [[ shut_down -eq 1 ]]; then
    date >>$dir_log/data.log
	echo "** shutdown system **" >> $dir_log/data.log
	shutdown now
fi
