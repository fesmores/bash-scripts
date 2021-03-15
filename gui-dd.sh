#!/bin/bash

if [[ $(id -u) -eq 0 ]];then

function format(){
	disk_selected=$1
	iso_selected=$2
	parted --script -a optimal "/dev/${disk_selected}" mklabel msdos
	parted --script -a optimal "/dev/${disk_selected}" mkpart primary 0% 100%
	sleep 1
	mkfs.ext4 "/dev/${disk_selected}1"
	sleep 2
	dd if=/mnt/disco500/OS-Images/ISOS-SO/${iso_selected} of=/dev/${disk_selected} bs=10M

}

	ISO_PATH="/mnt/disco500/OS-Images/ISOS-SO/"
	zenity --timeout=10000 --question --text="Script para crear un usb booteable.\n\nContinuar?"

	if [[ $? -eq 0  ]];then

		iso_selected=$(zenity --timeout=10000 --list --title "Isos Disponibles" --column="Iso" $(ls "${ISO_PATH}" | grep -vi windows | grep -v OLD) | sort )
		if [[ -z ${iso_selected}  ]];then
			zenity --error --text="No se selecciono ninguna imagen. Se sale"
			exit 1
		fi
		declare -a disks
		disks=$(lsblk -l | grep -v NAME |  grep -v sda | awk '{print $1}' | grep -vE "[0-9]+$")
		disk_selected=$(zenity --timeout=10000 --list --title "Discos Disponibles" --column="Disk" $(for i in ${disks[@]};do echo ${i};done))
		if [[ -z ${disk_selected} ]];then
			zenity --error --text="No se selecciono ningun disco. Se cancela"
			exit 1
		fi

		zenity --timeout=10000 --question --text="Se ha seleccionado la imagen\n\n${iso_selected}\n\nY el disco\n\n /dev/${disk_selected}\n\nCONFIRMAR"

		if [[ $? -eq 0  ]];then
			format "${disk_selected}" "${iso_selected}" | $(zenity --progress --title="Format ${disk_selected}" --text="Formateando el disco ${disk_selected}" --pulsate) && notify-send "Se formateo correctamente"	
		else
			zenity --error --text="Se cancelo la ejecucion del script"
			exit 1
		fi
	else
		exit 1
	fi
else
	zenity --error --text="Solo el usuario root puede ejecutar este script"
	exit 1
fi

