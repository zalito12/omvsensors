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
	read -p "Do you have lm-sensors already installed and configured? (y/n): " LM_SENSORS

	case $LM_SENSORS in
		y|Y)
			echo ""
			;;
		n|N)
			echo ""
			echo "You have to install and configure lm-sensors first"
			echo "Then you can rerun this script"
			echo "Exiting ..."
			exit 0
			;;
		*)
			echo ""
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
					echo -n "making backup of omv-sensor.conf ... "
					cp /etc/omv-sensor.conf /etc/omv-sensor.conf_bak  > /dev/null 2>&1
					f_checksuccess
					echo -n "omv-sensor.conf >>> /etc ... "
					cp omv-sensor.conf /etc > /dev/null 2>&1
					f_checksuccess
					break;;
				"Retain Current File")
					echo "omv-sensor.conf is not updated"
					break;;
			esac
		done
	else
		echo -n "omv-sensor.conf >>> /etc ..."
		cp omv-sensor.conf /etc > /dev/null 2>&1
		f_checksuccess
	fi

	echo -n "sensors >>> /usr/share/openmediavault/mkconf/collectd.d/ ... "
	cp sensors /usr/share/openmediavault/mkconf/collectd.d/ > /dev/null 2>&1
	f_checksuccess

	echo -n "Sensors.default >>> /var/www/openmediavault/js/omv/module/admin ... "
	cp Sensors.default /var/www/openmediavault/js/omv/module/admin/diagnostic/system/ > /dev/null 2>&1
	f_checksuccess
  
	echo -n "Temps.default >>> /var/www/openmediavault/js/omv/module/admin ... "
	cp Temps.default /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/ > /dev/null 2>&1
	f_checksuccess

	echo -n "Fanspeed.default /var/www/openmediavault/js/omv/module/admin ... "
	cp Fanspeed.default /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/ > /dev/null 2>&1
	f_checksuccess

	echo -n "HDDTemp.default /var/www/openmediavault/js/omv/module/admin ... "
	cp HDDTemp.default /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/ > /dev/null 2>&1
	f_checksuccess

	# new:
	read -p "Should this install-script make the changes for the first-time-setup? (y/n): " CONFIRM

	case $CONFIRM in
		y|Y)
			echo ""
			echo "Making changes ..."
			sleep 1
			echo -n "running '/usr/share/openmediavault/mkconf/collectd.d/sensors' ... "
			/usr/share/openmediavault/mkconf/collectd.d/sensors
			f_checksuccess

			echo "If you have errors here, it's due to missing rrd-files. You have to edit your /etc/omv-sensor.conf"
			echo "restarting collectd..."
			/etc/init.d/collectd restart
			f_checksuccess

			echo -n "creating graphs..."
			/usr/sbin/omv-mkgraph
			f_checksuccess

			echo ""
			echo "Installation completed!"
			echo "Edit /etc/omv-sensor.conf to fit your needs and run"
			echo "'/usr/share/openmediavault/mkconf/collectd.d/sensors'"
			echo "to create the rrd-scripts for OMV."
			echo "After install, you can delete the omvsensors-master folder"
			echo "Have fun!"
			;;
		n|N)
			echo ""
			echo "You have to make the changes by yourself"
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
	read -p "Do you want to remove all files from the sensors-script? (y/n): " LM_SENSORS_REMOVE

	case $LM_SENSORS_REMOVE in
		y|Y)
			echo ""
			;;
		n|N)
			echo ""
			echo "Nothing to do"
			echo "Exiting ..."
			exit 0
			;;
		*)
			echo ""
			echo "Please use y/n! Exiting ..."
			exit 0
			;;
	esac

	echo "Removing files ..."

	if [ -f /etc/omv-sensor.conf ]; then
		read -p "Remove omv-sensor.conf? (y/n): " OMV_SENSOR_REMOVE
		case $OMV_SENSOR_REMOVE in
			y|Y)
				echo ""
				echo -n "removing omv-sensor.conf ... "
				rm /etc/omv-sensor.conf > /dev/null 2>&1
				f_checksuccess
				;;
			n|N)
				echo ""
				echo "omv-sensor.conf is not removed"
				;;
			*)
				echo ""
				echo "Please use y/n!"
				echo "omv-sensor.conf is not removed"
				;;
		esac
	else
		echo "omv-sensor.conf not found"
	fi

	if [ -f /usr/share/openmediavault/mkconf/collectd.d/sensors ]; then
		echo -n "removing /usr/share/openmediavault/mkconf/collectd.d/sensors ... "
		rm /usr/share/openmediavault/mkconf/collectd.d/sensors > /dev/null 2>&1
		f_checksuccess
	else
		echo "/usr/share/openmediavault/mkconf/collectd.d/sensors not found!"
	fi

	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/Sensors.default ]; then
		echo -n "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/Sensors.default ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/Sensors.default > /dev/null 2>&1
		f_checksuccess
	else
		echo "/var/www/openmediavault/js/omv/module/admin/diagnostic/system/Sensors.default not found!"
	fi

	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Temps.default ]; then
		echo -n "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Temps.default ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Temps.default > /dev/null 2>&1
		f_checksuccess
	else
		echo "/var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Temps.default not found!"
	fi

	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.default ]; then
		echo -n "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.default ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.default > /dev/null 2>&1
		f_checksuccess
	else
		echo "/var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.default not found!"
	fi

	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.default ]; then
		echo -n "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.default ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.default > /dev/null 2>&1
		f_checksuccess
	else
		echo "/var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.default not found!"
	fi

	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/Sensors.js ]; then
		echo -n "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/Sensors.js ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/Sensors.js > /dev/null 2>&1
		f_checksuccess
	fi

	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.js ]; then
		echo -n "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.js ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Fanspeed.js > /dev/null 2>&1
		f_checksuccess
	fi
     
	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Temps.js ]; then
		echo -n "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Temps.js ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Temps.js > /dev/null 2>&1
		f_checksuccess
	fi

	if [ -f /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.js ]; then
		echo -n "removing /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.js ... "
		rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/HDDTemp.js > /dev/null 2>&1
		f_checksuccess
	fi

	echo "Removing completed!"
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