omvsensors
==========

Based on: fergbrain/omvsensors (https://github.com/fergbrain/omvsensors)
I just have applied some changes to make it works with OMV 2.x

OMV-script for easy setup of sensors (CPU Temperature, Fanspeed, and HDD Temperature)

Small installation step guide:

May be you need to remove some older version files
```
rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Sensors.default
rm  /var/www/openmediavault/js/omv/module/admin/diagnostic/system/plugin/Sensors.js
```

**Note: Do the following as root or sudo the commands:

1. Install lm-sensors in OpenMediaVault: `apt-get install lm-sensors`
1. Install hddtemp in OMV: `apt-get install hddtemp`

1. Detect your sensors in lm-sensors:
```
sensors-detect
```
Answer "yes" at the question: if the sensors should be added automatically

I answered yes to everything.

**WATCH! At the end it ask you to change some files and reload, I should accept and exec the command.

1. Check that your CPU temp sensors are working:
```
sensors
```
You should get something like:
```
~$ sensors
k10temp-pci-00c3
Adapter: PCI adapter
temp1:       +58.5°C  (high = +70.0°C, crit = +100.0°C)
```

Or something like this:
```
coretemp-isa-0000
Adapter: ISA adapter
Physical id 0:  +34.0°C  (high = +80.0°C, crit = +100.0°C)
Core 0:         +35.0°C  (high = +80.0°C, crit = +100.0°C)
Core 1:         +31.0°C  (high = +80.0°C, crit = +100.0°C)

nct6776-isa-0290
Adapter: ISA adapter
Vcore:          +0.86 V  (min =  +0.00 V, max =  +1.74 V)
in1:            +0.18 V  (min =  +0.00 V, max =  +0.00 V)  ALARM
AVCC:           +3.38 V  (min =  +2.98 V, max =  +3.63 V)
+3.3V:          +3.36 V  (min =  +2.98 V, max =  +3.63 V)
in4:            +0.50 V  (min =  +0.00 V, max =  +0.00 V)  ALARM
in5:            +1.82 V  (min =  +0.00 V, max =  +0.00 V)  ALARM
in6:            +1.70 V  (min =  +0.00 V, max =  +0.00 V)  ALARM
3VSB:           +3.44 V  (min =  +2.98 V, max =  +3.63 V)
Vbat:           +3.33 V  (min =  +2.70 V, max =  +3.63 V)
fan1:           979 RPM  (min =    0 RPM)
fan2:          1345 RPM  (min =    0 RPM)
fan3:             0 RPM  (min =    0 RPM)
fan4:             0 RPM  (min =    0 RPM)
fan5:             0 RPM  (min =    0 RPM)
SYSTIN:         +31.0°C  (high =  +0.0°C, hyst =  +0.0°C)  ALARM  sensor = thermistor
CPUTIN:         -58.0°C  (high = +80.0°C, hyst = +75.0°C)  sensor = thermistor
AUXTIN:         -14.5°C  (high = +80.0°C, hyst = +75.0°C)  sensor = thermistor
PECI Agent 0:   +34.0°C  (high = +80.0°C, hyst = +75.0°C)
                         (crit = +100.0°C)
PCH_CHIP_TEMP:   +0.0°C
PCH_CPU_TEMP:    +0.0°C
PCH_MCH_TEMP:    +0.0°C
intrusion0:    OK
intrusion1:    OK
beep_enable:   enabled
```
1. Download it: `wget https://github.com/zalito12/omvsensors/archive/master.zip`
1. Unpack it: `unzip master.zip` (Perhaps you have to install: apt-get install unzip)
1. Install it:

```
cd omvsensors-master
./install-remove.sh
```

The script will lead you through the installation (and if removal) process.

Edit '/etc/omv-sensor.conf' to fit your needs. Be careful choosing your temp files. 
In my case I have 3 core temp files, physical, core0, core1 and the core1 file is temp3 rrd.
 
Then run:
```
/usr/share/openmediavault/mkconf/collectd.d/sensors
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

May be you have to run
```
rm -f /var/cache/openmediavault/cache.*.json
```
to see the new tabs.

Now you should see A new Tab under Diagnostic > System info