# about 'MY-SHT31-humigadget'
Sensirion SHT31 Smart Humigadget - Temp and Humidity via Bluetooth on a demo-platform. Some scripting-up of my experience with a friend's 'SHT31 Smart Gadget Development Kit'.

# hardware notes about [Sensirion SHT31 RH and T Sensor Board](https://www.sensirion.com/en/environmental-sensors/humidity-sensors/development-kit/)
Though the SHT31 sensor itself is actually only small single black brick on any electronics board, the _SHT31 Smart Gadget Development Kit_ features some more:
- the SHT31 sensor chip, the main product of sensorion? driven in this case via I2C?
- a battery holder CR2032.
- a LCD-display, featuring temperature and humidity|dew-point 7-segment readings along with low-power and bt-indicator visuals.
- a single push-button. short-press -> switch humid/dew display. long-press -> switch bluetooth(*).
- a PCB that connects it all togehter, documented [here](https://github.com/Sensirion/SmartGadget-Hardware).
- a MCU that talks to SHT31/Button/LCD and has Bluetooth integrated. Firmware [here](https://github.com/Sensirion/SmartGadget-Firmware).

Note on bluetooth operation: 
- after power-on (insert battery), bt is NOT enabled. long-pressing the button will enable and disable bluetooth. 
- the LCD bt-logo will be blinking if not associated.
- the LCD bt-logo will steady screen if not associated (connected?).

# background
Topic Internet-of-things, subtopic sea-of-senors (oke, that's a HPE Proliant expression, but kind of is the idea): i'd like to deploy dozends of temperature sensors across the whole campus. But, turns out, if you like cover more than a one measurement point across multiple spots in multiple buildings, things suddenly get complicated.
So far i have not found a solution below 70USD per sensor if you want to place that sensor in specific place. e.g. monitoring environmental data of my Bathroom, livingroom, fridge, balcony or simply the cellar with the heater, it becomes complicated and expensive.

# prerequisits
- one of these [Smart Gadget Temperature and Humidity Development module](https://www.digitec.ch/de/s1/product/sensirion-sht31-temp-humidity-development-module-entwicklungsboard-kit-9717948)
- or the the same at [different price](https://www.digitec.ch/de/s1/product/sensirion-sht31-smart-gadget-sensor-elektronikmodul-6840205)
- TODO: remove digitec here as reference.
- A BT host adapter, i got a 'ID 0a12:0001 Cambridge Silicon Radio, Ltd Bluetooth Dongle (HCI mode)'
- Some distance between the USB-port and the BT-Antenna. Yes, Laptops, Screens and other electronics make noise. Have your USB-BT-Adapter some inches away from the USB port makes a difference of meteres of BT.
- ```sudo yum install bluez expect python``` (providing _gatttool_ and _hcitool_)

# get started - find your sensor
You should see some MAC-addresses belonging to any Sensirion devices?
```bash
sudo hciconfig hci0 down
sudo hciconfig hci0 up
sudo hcitool lescan
```

# runtime examples
```
[user@linux ~]$ ./SmartHumiGadget.sh C1:7F:33:F6:88:26
MAC=C1:7F:33:F6:88:26 TMP=21.65 HUM=36.59 BAT=88 NOW=20181227-042057
```

``` bash
while [ true ]; do
    ./SmartHumiGadget.sh C1:7F:33:F6:88:26
    sleep $((59 - `date +%S`)) # the rest of the minute
done | tee -a ~/SHT31.log
```

# follow-ups
- BT distance, i could not exceed more than ~12meters ... mybe the dev-module has a bad antenna?
- deplyoment, is a raspi sufficient for near-site translation between bluetooth and tcp/ip?
- hardware bt-enable at power on ... alter default firmware?
- do this all in parallel, query dozends of sensors at the same time? (asking one temp/humid takes now around 14 seconds)

# raw example
```
[user@linux ~]$ gatttool -I -b C1:7F:33:F6:88:26 -t random
[C1:7F:33:F6:88:26][LE]> connect
Attempting to connect to C1:7F:33:F6:88:26
Connection successful
[C1:7F:33:F6:88:26][LE]> char-read-uuid 00002235-b38d-4985-720e-0F993a68ee41
handle: 0x0037 	 value: 29 5c ad 41 
[C1:7F:33:F6:88:26][LE]> char-read-uuid 00001235-b38d-4985-720e-0F993a68ee41
handle: 0x0032 	 value: 71 3d 15 42 
[C1:7F:33:F6:88:26][LE]> char-read-uuid 2A19
handle: 0x001d 	 value: 58 
[C1:7F:33:F6:88:26][LE]> disconnect
[C1:7F:33:F6:88:26][LE]> exit
```