omvsensors
==========

OMV-script for easy setup of sensors (CPU Temperature, Fanspeed, and HDD Temperature)


#Requirements:

Based on Solo0815's instructions:
* http://forums.openmediavault.org/viewtopic.php?f=13&t=79&p=7459#p7459<br/>
* http://forums.openmediavault.org/viewtopic.php?f=13&t=79&start=60#p7374

And Jay-Jay instructions:
* http://forums.openmediavault.org/viewtopic.php?f=13&t=79&start=10#p925

__Note__: Please run your current install-remove script to delete any existing version of omvsensors before using this version, otherwise you risk leaving random files in places that could cause conflict. You may also need to delete Temperature.js, which can be done with:<br/>
`rm /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Temperature.js`


__Note__: Do the following as root or sudo the commands:

1. Install lm-sensors in OpenMediaVault: `apt-get install lm-sensors`
1. Install hddtemp in OMV: `apt-get install hddtemp`

1. Detect your sensors in lm-sensors:
```
sensors-detect
```
...answer "yes" at the question: if the sensors should be added automatically

1. Check that your CPU temp sensors are working:
```
sensors
```
...you should get something like:
```
~$ sensors
k10temp-pci-00c3
Adapter: PCI adapter
temp1:       +58.5°C  (high = +70.0°C, crit = +100.0°C)
```
1. Download it: `wget https://github.com/fergbrain/omvsensors/archive/master.zip`
1. Unpack it: `unzip master.zip`
1. Install it:

```
cd omvsensors-master
./install-remove.sh
```

The script will lead you through the installation (and if removal) process.

Edit '/etc/omv-sensor.conf' to fit your needs, then run:
```
/usr/share/openmediavault/scripts/collectd.d/sensors
```
...to create the rrd-scripts for OMV.

After that, please run:
```
/etc/init.d/collectd restart
```
...to collect the values for your coretemp/hddtemp/fanspeed. 

You can run:
```
omv-mkgraph
```
...to create the graphs.

Don't forget to run:
```
/usr/share/openmediavault/scripts/collectd.d/sensors
omv-mkgraph
```
...each time after changing the configuration file to make your changes happen in OMV
