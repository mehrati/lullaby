#!/bin/bash
root_pass=""
up_time=""
os_dist=""
ok_dist=""

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
	-t | --time)
		up_time=$2
		shift # past argument
		shift # past argument
		;;
	-p | --root-password)
		root_pass=$2
		shift # past argument
		shift # past argument
		;;
	-d | --distro-name)
		os_dist=$2
		shift # past argument
		shift # past value
		;;
	-h | --help)
		# help
		shift # past argument
		;;
	-v | --version)
		echo -e "[+] version 0.0.1 "
		shift # past argument
		;;
	*)
		# usage
		exit 1
		shift # past argument
		;;
	esac
done
echo $os_dist
declare -a deb_base=("debian" "ubuntu" "mint" "elemntry")
declare -a arch_base=("arch" "antergos" "manjaro")
if [ -z "$os_dist" ]; then
	if type lsb_release >/dev/null 2>&1; then
		os_dist=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
	else
		echo "please set os distribution name"
		exit 1
	fi
fi
function check_dist() {
	for i in "${deb_base[@]}"; do
		if [ $os_dist == $i ]; then
			ok_dist="debian"
			return 1
		fi
	done
	for i in "${arch_base[@]}"; do
		if [ $os_dist == $i ]; then
			ok_dist="arch"
			return 1
		fi
	done
	return 0
}

check_dist
if [ $? == 1 ]; then
	if [ -z "$up_time" ]; then
		echo "time arg empty"
		exit 1
	else
		echo $root_pass | sudo -S rtcwake -m mem -l -t $up_time
	fi
fi

if [ $ok_dist == "arch" ]; then
	echo $root_pass | sudo -u root --stdin pacman -Sy
	echo "Y" | sudo pacman -Suy
	echo "arch"
elif [ $ok_dist == "debian" ]; then
	echo $root_pass | sudo -u root --stdin sudo apt update
	sudo apt upgrade -y
	echo "deb"
fi
