#!/bin/bash

dir_log=$HOME/lullaby/
shut_down=0
declare -a deb_base=("debian" "ubuntu" "mint" "elementary" "kali")
declare -a arch_base=("arch" "antergos" "manjarolinux")
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
	-u | --url-file)
		url_file=$2
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
		echo "lullaby version 0.0.2 alpha"
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
	if type nmcli >/dev/null 2>&1; then
		nmcli radio wifi on
		declare -a uuids=($(nmcli -f UUID con show | sed '/UUID/d'))
		for uid in "${uuids[@]}"; do
			nmcli con up uuid $uid | tee -a $dir_log/data.log
			sleep 1
			if ping google.com -c 3 1>/dev/null 2>&1; then
				echo "Connect to internet ..." | tee -a $dir_log/data.log
				break
			fi
		done
	else
		echo "nmcli not installed " | tee -a $dir_log/data.log
	fi
fi

if ping google.com -c 3 1>/dev/null 2>&1; then

	if which pip >/dev/null 2>&1; then
		pypkgs=$(echo $root_pass | sudo -u root --stdin pip freeze --local | grep -v '^\-e' | cut -d = -f 1)
		echo $pypkgs | xargs -n1 sudo pip install -U | tee -a $dir_log/data.log
		echo "####*** Update Python Package Finish At $(date) ***####" >>$dir_log/data.log
	fi
	if which npm >/dev/null 2>&1; then
		echo $root_pass | sudo -u root --stdin npm update -g | tee -a $dir_log/data.log
		echo "####*** Update Node Package Finish At $(date) ***####" >>$dir_log/data.log
	fi
	if which cargo >/dev/null 2>&1; then
		if which rustup >/dev/null 2>&1; then
			rustup update | tee -a $dir_log/data.log
			echo "####*** Update Rustc Finish At $(date) ***####" >>$dir_log/data.log
		fi
		if which cargo install-update >/dev/null 2>&1; then
			cargo install-update -a 1>>$dir_log/data.log 2>&1
			echo "####*** Update Rust Package Finish At $(date) ***####" >>$dir_log/data.log
		else
			cargo install cargo-update 1>>$dir_log/data.log 2>&1
			cargo install-update -a 1>>$dir_log/data.log 2>&1
			echo "####*** Update Rust Package Finish At $(date) ***####" >>$dir_log/data.log
		fi
	fi
	if which go >/dev/null 2>&1; then
		go get -v -u all 1>>$dir_log/data.log 2>&1
		echo "####*** Update Golang Package Finish At $(date) ***####" >>$dir_log/data.log
	fi

	if [ $distro_base == "arch" ]; then
		echo $root_pass | sudo -u root --stdin pacman -Sy | tee -a $dir_log/data.log
		echo "####*** Update System Finish At $(date) ***####" >>$dir_log/data.log
		echo "Y" | sudo pacman -Su | tee -a $dir_log/data.log
		echo "####*** Upgrade System Finish At $(date) ***####" >>$dir_log/data.log
		if which yaourt >/dev/null 2>&1; then
			echo $root_pass | yaourt -Sy | tee -a $dir_log/data.log
			echo "####*** Update AUR Finish At $(date) ***####" >>$dir_log/data.log
			echo "Y" | yaourt -Su | tee -a $dir_log/data.log
			echo "####*** Upgrade AUR Finish At $(date) ***####" >>$dir_log/data.log
		elif which pacaur >/dev/null 2>&1; then
			echo $root_pass | pacaur -Sy | tee -a $dir_log/data.log
			echo "####*** Update AUR Finish At $(date) ***####" >>$dir_log/data.log
			echo "Y" | pacaur -Su | tee -a $dir_log/data.log
			echo "####*** Upgrade AUR Finish At $(date) ***####" >>$dir_log/data.log
		fi
	elif [ $distro_base == "debian" ]; then
		echo $root_pass | sudo -u root --stdin sudo apt update | tee -a $dir_log/data.log
		echo "####*** Update System Finish At $(date) ***####" >>$dir_log/data.log
		sudo apt upgrade -y | tee -a $dir_log/data.log
		echo "####*** Upgrade System Finish At $(date) ***####" >>$dir_log/data.log
	fi
else
	echo "####*** System disconnected ***####" >>$dir_log/data.log
fi

if [ -f "$url_file" ]; then
	if type aria2c >/dev/null 2>&1; then
		aria2c --input-file $url_file
	fi
fi

if [[ shut_down -eq 1 ]]; then
	clear
	declare -a ch=("/" "|" "\\")

	for i in $(seq 10 -1 0); do
		for c in "${ch[@]}"; do
			printf "\r[+] $i Second To Shutdown System... $c "
			sleep 0.25
		done
		sleep 0.25
	done
	echo "####*** Shutdown System At $(date) ***####" >>$dir_log/data.log
	shutdown now
fi
