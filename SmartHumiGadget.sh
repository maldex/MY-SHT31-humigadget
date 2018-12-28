#!/usr/bin/bash
function log(){ echo >&2 "$@"; }

function hex_to_float(){ 
cat << EOF | python
import struct
print('%.2f' % struct.unpack('!f', '$1'.decode('hex')))
EOF
}

function analye_humigadget(){
   MAC=$1
   ./SmartHumiGadget.exp ${MAC} | grep "^${MAC} " > /tmp/humigadget.${MAC}
   if [ "`du /tmp/humigadget.${MAC} | awk '{print $1}'`" == "0" ]; then
       echo >&2 "mac address ${MAC} did not respond well"
	   return 1
	   fi
   TMP=`cat /tmp/humigadget.${MAC} | grep "TEMPERATURE" | awk '{for(i=NF-1;i>=NF-4;i--) printf $i}'`
   HUM=`cat /tmp/humigadget.${MAC} | grep "HUMIDITY" | awk '{for(i=NF-1;i>=NF-4;i--) printf $i}'`
   BAT=`cat /tmp/humigadget.${MAC} | grep "BATTERY" | awk '{print $(NF-1)}'`
   TMP=`hex_to_float ${TMP}`
   HUM=`hex_to_float ${HUM}`
   BAT=`echo "print(0x${BAT})" | python`
   echo "${MAC} ${TMP} ${HUM} ${BAT}"
   rm /tmp/humigadget.${MAC}
}

function report_humigadget() {
    read MAC TMP HUM BAT <<< `analye_humigadget $1`
    if [ -z "${MAC}" ]; then return 1; fi
    echo "NOW='`date +"%Y.%m.%d %H:%M:%S"`' MAC=${MAC} TMP=${TMP} HUM=${HUM} BAT=${BAT}"
}

### here we actually go

MAC=$1
if [ -z "${MAC}" ]; then MAC="C1:7F:33:F6:88:26"; fi

sudo hciconfig hci0 down
sudo hciconfig hci0 up

report_humigadget ${MAC}

exit $?








############### further functions - not to be used yet - don't try at home

function bt_lescan() {
    timeout=$1
    if [ "${timeout}" == "" ]; then timeout=5; fi
    sudo hciconfig hci0 down
    sudo hciconfig hci0 up
    sudo hcitool lescan > /tmp/hcitool.lescan.$$ &
    pid=$!
    sleep ${timeout}
    sudo kill -INT $pid
    wait $pid
}

function find_all_humigadgets() {
    log "scanning bluetooth for 'Smart Humigadgets'"
    bt_lescan 2>/dev/null
	log "$((`wc -l /tmp/hcitool.lescan.$$` - 1)) devices appeared total"
    cat /tmp/hcitool.lescan.$$ | grep "Smart Humigadget" | uniq | cut -d' ' -f 1
}


#for mac in `find_all_humigadgets`; do
#    ./SmartHumiGadget.exp ${mac}
#done