#!/bin/bash
################################################################################
# Written by: K7-Avenger                                                       #
# For: Metro State CCDC 2023                                                   #
# Purpose: To update Debian 8 to Debian 12                                     #
################################################################################

updateDeb8(){
  cp /etc/apt/sources.list /etc/apt/sources.list.orig
  echo "deb http://archive.debian.org/debian jessie main contrib non-free" > /etc/apt/sources.list
  echo "deb-src http://archive.debian.org/debian jessie main contrib non-free" >> /etc/apt/sources.list

  echo "deb http://archive.debian.org/debian jessie-backports main contrib non-free" >> /etc/apt/sources.list
  echo "deb-src http://archive.debian.org/debian jessie-backports main contrib non-free" >> /etc/apt/sources.list

  echo "deb http://archive.debian.org/debian-security jessie/updates main contrib non-free" >> /etc/apt/sources.list
  echo "deb-src http://archive.debian.org/debian-security jessie/updates main contrib non-free" >> /etc/apt/sources.list

  echo "/root/rare_candy.sh -a" >> /etc/profile
  apt-get update && apt-get dist-upgrade --force-yes -y
  apt-get autoremove -y && shutdown -r +0
}

updateToDeb10(){
  cp /etc/apt/sources.list /etc/apt/sources.list.8
  
  echo "deb http://deb.debian.org/debian buster main contrib non-free" > /etc/apt/sources.list
  echo "deb-src http://deb.debian.org/debian buster main contrib non-free" >> /etc/apt/sources.list

  echo "deb http://deb.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list
  echo "deb-src http://deb.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list

  echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" >> /etc/apt/sources.list
  echo "deb-src http://deb.debian.org/debian buster-backports main contrib non-free" >> /etc/apt/sources.list

  echo "deb http://deb.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list
  echo "deb-src http://deb.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list

  sed -i 's/rare_candy.sh -a/rare_candy.sh -b/g' /etc/profile
  apt-get update && apt-get dist-upgrade --force-yes -y
  apt-get autoremove -y && shutdown -r +0
}

updateToDeb11(){
  cp /etc/apt/sources.list /etc/apt/sources.list.10
  
  echo "deb http://deb.debian.org/debian bullseye main contrib non-free" > /etc/apt/sources.list
  echo "deb-src http://deb.debian.org/debian bullseye main contrib non-free" >> /etc/apt/sources.list

  echo "deb http://deb.debian.org/debian bullseye-updates main contrib non-free" >> /etc/apt/sources.list
  echo "deb-src http://deb.debian.org/debian bullseye-updates main contrib non-free" >> /etc/apt/sources.list

  echo "deb http://deb.debian.org/debian bullseye-backports main contrib non-free" >> /etc/apt/sources.list
  echo "deb-src http://deb.debian.org/debian bullseye-backports main contrib non-free" >> /etc/apt/sources.list

  echo "deb http://deb.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list
  echo "deb-src http://deb.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list

  sed -i 's/rare_candy.sh -b/rare_candy.sh -c/g' /etc/profile
  apt-get update && apt-get dist-upgrade --force-yes -y
  apt-get autoremove -y && shutdown -r +0
}

updateToDeb12(){
  cp /etc/apt/sources.list /etc/apt/sources.list.11
  
  echo "deb http://deb.debian.org/debian bookworm main contrib non-free-frimware non-free" > /etc/apt/sources.list
  echo "deb-src http://deb.debian.org/debian bookworm main contrib non-free-frimware non-free" >> /etc/apt/sources.list

  echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free-frimware non-free" >> /etc/apt/sources.list
  echo "deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free-frimware non-free" >> /etc/apt/sources.list

  echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free-frimware non-free" >> /etc/apt/sources.list
  echo "deb-src http://deb.debian.org/debian bookworm-backports main contrib non-free-frimware non-free" >> /etc/apt/sources.list

  echo "deb http://deb.debian.org/debian-security bookworm-security main contrib non-free-frimware non-free" >> /etc/apt/sources.list
  echo "deb-src http://deb.debian.org/debian-security bookworm-security main contrib non-free-frimware non-free" >> /etc/apt/sources.list

  apt-get update && apt-get dist-upgrade --force-yes -y
  apt-get autoremove -y && shutdown -r +0
}

while getopts 'abc :' OPTION; do
	case "$OPTION" in
		a)
			updateToDeb10
			;;
		b)
			updateToDeb11
			;;
		c)
			updateToDeb12
			;;
		?)
			echo -e -n "${YELLOW}"
			echo -e "Correct usage:\t $(basename $0) -flag(s)"
			echo -e "-a\t Perform initial upgrade process"
			echo -e "-b\t Perform secondary upgrade process"
			echo -e "-c\t Perform tertiary upgrade process"
			echo -e "${RESET}"
			exit 1
			;;
	esac
done
