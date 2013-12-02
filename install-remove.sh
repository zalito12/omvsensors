#!/bin/bash

# Install/Remove script for OMV-sensors script
# Use it with OMV

# Author: Solo0815, fergbrain <andrew@fergcorp.com>
# feel free to edit this file, but please share it in
# the OMV-Forum: http://forums.openmediavault.org/viewtopic.php?f=13&t=79#p244

# Version 0.6

##### Shell-Colors
GREEN="\033[0;32m"
RED='\e[0;31m'
NC='\033[0m'        # No Color

######################################################
# Functions

#checks, if the command was successfull
f_checksuccess() {
	if [ $? -ne 0 ] ; then # Last Action returns an error $1=1
		echo -e "${RED}failed!$NC" ; sleep 1
	else # if successfull $1=0
		echo -e "${GREEN}successfull!$NC" ; sleep 1
	fi
}

# Install all the files to OMV - omv-sensors.conf can be chosen to overwrite or keep
f_install() {
	echo -n "Do you have lm-sensors already installed and configured? (y/n) "
	read -n 1 LM_SENSORS

	case $LM_SENSORS in
		y|Y)
			;;
		n|N)
			echo "You have to install and configure lm-sensors first"
			echo "Then you can rerun this script"
			echo "Exiting ..."
			exit 0
			;;
		*)
			echo "Please use y/n! Exiting ..."
			exit 0
			;;
	esac

	sleep 1
	echo "Installing files..."

	if [ -f /etc/omv-sensor.conf ]; then
		echo "omv-sensor.conf exists - What to do?"
		echo "Note: If you install the default file, your existing changes will be backed up."
		select OMV_SENSOROVERWRITE in "Install Default File" "Retain Current File"; do
			case $OMV_SENSOROVERWRITE in
				"Install Default File" )
					echo "making backup of omv-sensor.conf ... "
					cp /etc/omv-sensor.conf /etc/omv-sensor.conf_bak  > /dev/null 2>&1
					f_checksuccess
					echo "omv-sensor.conf >>> /etc ... "
					cp omv-sensor.conf /etc > /dev/null 2>&1
					f_checksuccess
					break;;
				"Retain Current File")
					echo -e "omv-sensor.conf is not updated"
					break;;
			esac
		done
	else
		echo "omv-sensor.conf >>> /etc ..."
		cp omv-sensor.conf /etc > /dev/null 2>&1
		f_checksuccess
	fi

	echo -ne "\nsensors >>> /usr/share/openmediavault/mkconf/collectd.d/ ... "
	cp sensors /usr/share/openmediavault/mkconf/collectd.d/ > /dev/null 2>&1
	f_checksuccess

	echo -ne "Sensors.default >>> /var/www/openmediavault/js/omv/module/admin ... "
	cp Sensors.default /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/ > /dev/null 2>&1
	f_checksuccess

	echo -ne "Fanspeed.default /var/www/openmediavault/js/omv/module/admin ... "
	cp Fanspeed.default /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/ > /dev/null 2>&1
	f_checksuccess

	echo -ne "HDDTemp.default /var/www/openmediavault/js/omv/module/admin ... "
	cp HDDTemp.default /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/ > /dev/null 2>&1
	f_checksuccess

	# new:
	echo -ne "\nShould this install-script make the changes for the first-time-setup? (y/n) "
	read -n 1 CONFIRM

	case $CONFIRM in
		y|Y)
			echo -e "\n\nMaking changes ..."
			sleep 1
			echo -e "\nrunning '/usr/share/openmediavault/mkconf/collectd.d/sensors' ... "
			echo
			/usr/share/openmediavault/mkconf/collectd.d/sensors
			f_checksuccess

			echo -e "\nIf you have errors here, it's due to missing rrd-files. You have to edit your /etc/omv-sensor.conf"
			echo -e "\nrestarting collectd ..."
			/etc/init.d/collectd restart
			f_checksuccess

			echo "creating graphs ..."
			/usr/sbin/omv-mkgraph
			f_checksuccess

			echo -e "Installation completed!"
			echo -e "\nEdit /etc/omv-sensor.conf to fit your needs and run"
			echo "'/usr/share/openmediavault/mkconf/collectd.d/sensors'"
			echo -e "to create the rrd-scripts for OMV.\n"
			echo -e "After install, you can delete the omvsensors-master folder\n"
			echo "Have fun!"
			;;
		n|N)
			echo -e "\n\nYou have to make the changes by yourself"
			cat <<EOF
Please install and configure lm-sensors (if not already done)

Edit /etc/omv-sensor.conf to fit your needs
and run '/usr/share/openmediavault/mkconf/collectd.d/sensors'
to create the rrd-scripts for OMV.

After that, please run '/etc/init.d/collectd restart'
to collect the values for your coretemp/fanspeed/HDDTemp. You can run 
'omv-mkgraph' to create the graphs.

After install, you can delete this folder

Have fun!

EOF
			exit 0
			;;
		*)
			echo "Please use y/n! Exiting ..."
			exit 0
			;;
	esac
}

# Remove all the files from OMV - omv-sensors.conf can be chosen to remove or keep
f_remove() {
	echo -n "Do you want to remove all files from the sensors-script? (y/n) "
	read -n 1 LM_SENSORS_REMOVE

	case $LM_SENSORS_REMOVE in
		y|Y)
			;;
		n|N)
			echo "Nothing to do"
			echo "Exiting ..."
			exit 0
			;;
		*)
			echo "\n\nPlease use y/n! Exiting ..."
			exit 0
			;;
	esac

	echo -e "\n\nRemoving files ..."

	if [ -f /etc/omv-sensor.conf ]; then
		echo -ne "\nRemove omv-sensor.conf? (y/n)"
		read -n 1 OMV_SENSOR_REMOVE
		case $OMV_SENSOR_REMOVE in
			y|Y)
				echo -ne "\n\nremoving omv-sensor.conf ... "
				rm /etc/omv-sensor.conf > /dev/null 2>&1
				f_checksuccess
				;;
			n|N)
				echo -e "\n\nomv-sensor.conf is not removed"
				;;
			*)
				echo "\n\nPlease use y/n!"
				echo -e "\n\nomv-sensor.conf is not removed"
				;;
		esac
	else
		echo -ne "\n\nomv-sensor.conf not found"
	fi

	if [ -f /usr/share/openmediavault/mkconf/collectd.d/sensors ]; then
		echo -ne "\nremoving /usr/share/openmediavault/mkconf/collectd.d/sensors ... "
		rm /usr/share/openmediavault/mkconf/collectd.d/sensors > /dev/null 2>&1
		f_checksuccess
	else
		echo -ne "\n/usr/share/openmediavault/mkconf/collectd.d/sensors not found!"
	fi

	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Sensors.default ]; then
		echo -ne "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Sensors.default ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Sensors.default > /dev/null 2>&1
		f_checksuccess
	else
		echo -ne "\n/var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Sensors.default not found!"
	fi

	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.default ]; then
		echo -ne "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.default ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.default > /dev/null 2>&1
		f_checksuccess
	else
		echo -ne "\n/var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.default not found!"
	fi

	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.default ]; then
		echo -ne "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.default ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.default > /dev/null 2>&1
		f_checksuccess
	else
		echo -ne "\n/var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.default not found!"
	fi

	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.js ]; then
		echo -ne "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.js ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.js > /dev/null 2>&1
		f_checksuccess
	fi

	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Sensors.js ]; then
		echo -ne "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Sensors.js ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Sensors.js > /dev/null 2>&1
		f_checksuccess
	fi

	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.js ]; then
		echo -ne "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.js ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.js > /dev/null 2>&1
		f_checksuccess
	fi

	echo -e "Removing completed!"
	echo "Have fun!"
}

######################################################
# Main Body of script

cat <<EOF


######################################################
###                                                ###
###      OMV-sensors Install / Remove script       ###
###                                                ###
######################################################


EOF

echo "Sensors-script Installation / Remove in OMV?"
select OMV_SENSOR_INST_REM in "Install" "Remove"; do
	case $OMV_SENSOR_INST_REM in
	Install )
		echo
		echo
		f_install
		break;;
	Remove )
		echo
		echo
		f_remove
		break;;
	esac
done
exit 0