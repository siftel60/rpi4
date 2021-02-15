#!/bin/sh
############ORIGINAL#####!/bin/bash 


NPROC_DEFAULT=2
#@parse not NPROC_OS(yet) or NPROC(sslbenchfinal)





#set -x
#echo "DBGTOP $0 ${*}"; sleep 2








cleanupsslbench() {

	BENCHpids=$(ps w | sed 's!^[[:space:]]!!g' | grep -v grep | grep 'openssl speed' | cut -d' ' -f1 | tr -s '\n' ' ')
	echo "ending: $BENCHpids" #echo "DBG kill -9 $ENDbench: $(ps w | grep "^$ENDbench ")"

	while read ENDbench; do
		#echo "Cleanup-stale-sslbench: $ENDbench"

		echo "end: $ENDbench"
		kill -9 $ENDbench
		#sleep 1
	
	done <<LLL
$(ps w | sed 's!^[[:space:]]!!g' | grep -v grep | grep 'openssl speed' | sort | uniq | cut -d' ' -f1)
LLL
}










#@@@faulty-exclude-me->blockscleanup
#if ps w | grep -v grep | sed 's!^[[:space:]]!!g' | grep -v "^$$" | \
#	grep -q "$(basename $0)"; then
#	echo "$0 already running cleanup?"
#	ps w | grep -v grep | sed 's!^[[:space:]]!!g' | grep -v "^$$" | grep "$(basename $0)"
#	exit 0
#fi






if ps w | grep -v grep | grep -q 'openssl speed' || [ "$1" = "cleanup" ]; then
	CLEANUP=1
fi




if [ ! -z "$CLEANUP" ]; then

	if ps w | grep -v grep | grep -q 'openssl speed'; then
		BENCHpids=$(ps w | sed 's!^[[:space:]]!!g' | grep -v grep | grep 'openssl speed' | cut -d' ' -f1 | tr -s '\n' ' ')
		echo "openssl-speed is running $BENCHpids"
		sleep 2

		cleanupsslbench

	else
		echo "nothing to cleanup"

	fi
	

	exit 0

fi
#echo "openssl-speed is running $(ps w | grep -v grep | grep 'openssl speed')"
#ps w | grep 'openssl speed' | grep -v grep | while read SSLpid theREST; do kill -9 $SSLpid; done
#exit 0



















help() {
cat <<TTT


$0		
$0	[-P]	[-C <N>]

		-P		#test psu
		-C <nproc>


TTT

}

#P number of vcore state changes; time to 60deg


















#while getopts dehilSI'-C' opt #ORIGINAL while getopts dehilS opt; #NOPE while getopts dehil:S opt
while getopts dehilSICP opt #ORIGINAL while getopts dehilS opt; #NOPE while getopts dehil:S opt
do #echo "DBG getopt: $opt"; sleep 2
	case "$opt" in

		i) ACTION=interfaces; ;;
		h) ACTION=help; ;;
		d) ACTION=devices; ;;


		C) 
			NPROC="$2" #opt=C as -C echo "OPT: $opt"; echo "2: $2"
			shift
		;;
		P) #testpsu
			#NPROC=4
			NPROC=${NPROC_DEFAULT:-1}
			RUNSSLBENCH=1
		;;
		S) RUNSSLBENCH=1; ;; #S) OUTPUTis=simple;; #NO -S) OUTPUTis=simple


		l) LIST_ONLY=1; ;;
		e) USE_REGEX=1; ;;
		

		I) ACTION=ipinfo; ;;
		


		*) help; echo "ERROR: Invalid option '$1'!"; exit 1;;
	esac #shift #ORIGINALBUT-GETOPTAUTOSHIFTS
done

shift $((OPTIND-1)) ######################## ADDED shift $((OPTIND-1)); OTHERARGS=$@
ARGS="$@" #ORIGINAL ARGS="$*"



































newphase() {



#Health not populating? use :-5@if? @@@? on-zeros @ hex 0x00000 health does not convert-properly->perlcmd







HealthHex=$(vcgencmd get_throttled | cut -f2 -d=)
Health=$(perl -e "printf \"%19b\n\", $(vcgencmd get_throttled | cut -f2 -d=)")
#RUMMY
if [ "$Health" = "0" ]; then
	Health=0000000000000000000
fi

#echo "$HealthHex $Health"; sleep 1 #1010000000000000000
#echo "$HealthHex $Health"; sleep 1 #
#echo "DBG    HealthHex: $HealthHex"
#echo "DBG       Health: $Health"




###################################################################### REPORTS
Hbit19=$(echo $Health | cut -c1)
#echo "19:$Hbit19" #19 "first" #Hbit19=$(echo $Health | cut -c19)
if [ "$Hbit19" -eq 1 ]; then echo "Soft temp limit has occurred"; fi

Hbit18=$(echo $Health | cut -c2)
#echo "18:$Hbit18" #| 18 | Throttling has occurred |
if [ "$Hbit18" -eq 1 ]; then echo "Throttle has occurred"; fi


Hbit17=$(echo $Health | cut -c3)
#echo "17:$Hbit17" #| 17 | Arm frequency capped has occurred |
if [ "$Hbit17" -eq 1 ]; then echo "Arm frequency capped has occurred"; fi

Hbit16=$(echo $Health | cut -c4)
#echo "16:$Hbit16" #| 16 | Under-voltage has occurred |
if [ "$Hbit16" -eq 1 ]; then echo "Under-voltage has occurred"; fi


################################################################### DYNAMICAKACOUNTERS
Hbit1=$(echo $Health | cut -c19)
if [ "$Hbit1" -eq 1 ]; then echo "Under-voltage detected"; fi
#if [ "$Hbit1" -eq 0 ]; then echo "Under-voltage detectedno"; fi

Hbit2=$(echo $Health | cut -c18)
if [ "$Hbit2" -eq 1 ]; then echo "Frequency Capped"; fi
#if [ "$Hbit2" -eq 0 ]; then echo "Frequency Not Capped"; fi

Hbit3=$(echo $Health | cut -c17)
if [ "$Hbit3" -eq 1 ]; then echo "Currently throttled"; fi
#if [ "$Hbit3" -eq 0 ]; then echo "Not Currently throttled"; fi

Hbit4=$(echo $Health | cut -c16)
if [ "$Hbit4" -eq 1 ]; then echo "Soft temp limit active"; fi
#if [ "$Hbit4" -eq 0 ]; then echo "Soft temp limit notactive"; fi
#exit 0


}
















if [ ! -z "$(command -v nproc 2>/dev/null)" ]; then
	NPROC_OS=$(nproc)
fi #NPROC=4 later-replaced-of-given-aka-notalwaysreal




###NPROC for opensslbench needs @parse and set/validate default
NPROC=${NPROC:-2}
NORPTHEADER=1
sPID=$$






echo "NPROC:$NPROC_OS RUNSSLBENCH:${RUNSSLBENCH:-off} NPROC_SSL:$NPROC"






#if REPORTVALS >> #### newphase +exit

#@@@NPROC is 2 then 4
#for P in `seq 1 20`; do
#	NPROC=${NPROC:-2}
#	echo "NPROC:$NPROC RUNSSLBENCH:$RUNSSLBENCH"
	#### newphase
#done
#sleep 2
#exit 0









if [ ! -z "$RUNSSLBENCH" ]; then

#if ! -z "MAXTIME" ; then || WHILE pgrep $$ sleep 10; done; 
#(sleep MAXTIME &&
#ps w | grep 'openssl speed' | grep -v grep | while read SSLpid theREST; do kill -9 $SSLpid; done
#) &
#fi


echo "starting opensslbench with $NPROC cores"; sleep 1




#@@@absolutepathto$0?
#echo "(while [ ! -z "$(ps w | sed 's!^[[:space:]]!!g' | grep "^$$ ")" ]; do sleep 3; done; $0 cleanup) &" 
(while [ ! -z "$(ps w | sed 's!^[[:space:]]!!g' | grep "^$$ ")" ]; do sleep 1; done; $0 cleanup) &



(openssl speed -multi ${NPROC} md5 sha1 sha256 sha512 des des-ede3 aes-128-cbc aes-192-cbc aes-256-cbc rsa2048 dsa2048 2>/dev/null 1>/dev/null; echo "OPENSSL-BENCH-ENDED") &

fi









################################################################################### ORIGINAL

INTERVAL=3 #10
Counter=14
DisplayHeader="Time       Temp     CPU     Core         Health           Vcore"
while true ; do
  let ++Counter
  if [ ${Counter} -eq 15 ]; then
    echo -e "${DisplayHeader}"
    Counter=0
  fi
  if [ ! -z "$NORPTHEADER" ]; then Counter=0; fi
  Health=$(perl -e "printf \"%19b\n\", $(vcgencmd get_throttled | cut -f2 -d=)")
  Temp=$(vcgencmd measure_temp | cut -f2 -d=)
  Clockspeed=$(vcgencmd measure_clock arm | awk -F"=" '{printf ("%0.0f",$2/1000000); }' )
  Corespeed=$(vcgencmd measure_clock core | awk -F"=" '{printf ("%0.0f",$2/1000000); }' )
  CoreVolt=$(vcgencmd measure_volts | cut -f2 -d= | sed 's/000//')
  echo -e "$(date '+%H:%M:%S')  ${Temp}  $(printf '%4s' ${Clockspeed})MHz $(printf '%4s' ${Corespeed})MHz  $(printf '%020u' ${Health})  ${CoreVolt}"
  sleep $INTERVAL
done







ps w | grep 'openssl speed' | grep -v grep | while read SSLpid theREST; do kill -9 $SSLpid; done








exit 0


















#(opensslbenchM.sh -m >/dev/null 2>/dev/null; echo "BENCHMARK-ENDED") &
#openssl speed -multi 2 md5 sha1 sha256 sha512 des des-ede3 aes-128-cbc aes-192-cbc aes-256-cbc rsa2048 dsa2048 | tee /tmp/sslspeed
#NOPE(openssl speed -multi 4 md5 sha1 sha256 sha512 des des-ede3 aes-128-cbc aes-192-cbc aes-256-cbc rsa2048 dsa2048 2>&1 > /tmp/sslspeed) &






####################################################
#case "$Health" in
#	1*) :; ;;
#	[0-1]1*) :; ;;
#	[0-1][0-1]1*) : ;;
#esac
#####################################################
#| Bit | Meaning |
#|:---:|---------|
#| 0 | Under-voltage detected |
#| 1 | Arm frequency capped |
#| 2 | Currently throttled |
#| 3 | Soft temperature limit active |
#| 16 | Under-voltage has occurred |
#| 17 | Arm frequency capped has occurred |
#| 18 | Throttling has occurred |
#| 19 | Soft temperature limit has occurred
#####################################################
#}







#opensslbench.sh -m &


####################[root@dca632 /usbstick 48°]# ./throttlehealthbash.sh 
cat <<'LLL'
Time       Temp     CPU     Core         Health           Vcore
06:01:23  47.0'C  1000MHz  333MHz  01010000000000000000  0.8375V
06:01:33  48.0'C  1000MHz  333MHz  01010000000000000000  0.8375V
06:01:43  47.0'C  1000MHz  333MHz  01010000000000000000  0.8375V
06:01:53  47.0'C  1000MHz  333MHz  01010000000000000000  0.8375V
06:02:03  52.0'C  1500MHz  500MHz  01010000000000000000  0.8375V <<RAMPsUP
06:02:13  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:02:23  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:02:33  55.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:02:43  55.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:02:53  57.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:03:03  56.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:03:13  57.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:03:23  56.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:03:33  57.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:03:43  58.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
Time       Temp     CPU     Core         Health           Vcore
06:03:53  59.0'C  1500MHz  500MHz  01010000000000000000  0.8375V <<<59DEG
06:04:03  56.0'C   600MHz  200MHz  01010000000000000101  0.8350V <<<THROTTLED(+||UNDERVOLTAGE?)
06:04:13  58.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:04:23  57.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:04:33  59.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:04:43  57.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:04:54  57.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:05:04  58.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:05:14  57.0'C  1500MHz  500MHz  01010000000000000000  0.8375V <<BENCHSTOPS
06:05:24  54.0'C  1000MHz  333MHz  01010000000000000000  0.8375V
06:05:34  52.0'C  1500MHz  333MHz  01010000000000000000  0.8375V <<RAMDOWNQUIRK?
06:05:44  52.0'C  1000MHz  333MHz  01010000000000000000  0.8375V
06:05:54  51.0'C  1000MHz  333MHz  01010000000000000000  0.8375V
06:06:04  50.0'C  1000MHz  333MHz  01010000000000000000  0.8375V





################ INTERESTING SAME SCRIPT ~ via ssh ################# FORKS opensshbenchM.sh -m &
################ CORRECTION THIS WAS bench.sh -s
[root@dca632 /usbstick 50°]# ./throttlehealthbash.sh
0x50000 1010000000000000000
Soft temp limit has occurred
Arm frequency capped has occurred
Time       Temp     CPU     Core         Health           Vcore
06:36:23  49.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:36:26  52.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:36:29  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:36:32  52.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:36:35  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:36:38  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:36:41  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:36:44  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:36:47  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:36:50  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:36:53  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:36:56  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:36:59  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:02  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:05  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
Time       Temp     CPU     Core         Health           Vcore
06:37:08  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:11  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:14  55.0'C  1500MHz  500MHz  01010000000000000000  0.8375V << CAPPED
06:37:17  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:20  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:24  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:27  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:30  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:33  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:36  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:39  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:42  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:45  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:48  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:51  52.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
Time       Temp     CPU     Core         Health           Vcore
06:37:54  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:37:57  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:00  52.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:03  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:06  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:09  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:12  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:15  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:18  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:21  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:24  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:27  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:30  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:33  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:36  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
Time       Temp     CPU     Core         Health           Vcore
06:38:39  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:42  55.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:45  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:48  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:51  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:54  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:38:57  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:00  55.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:03  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:06  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:09  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:12  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:15  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:18  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:21  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
Time       Temp     CPU     Core         Health           Vcore
06:39:24  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:27  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:30  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:33  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:37  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:40  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:43  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
BENCHMARK-ENDED


################################################################## THEN START ANOTHER BENCH FROM SERIAL CONSOLE NOLIMITS
06:39:46  53.0'C  1000MHz  333MHz  01010000000000000000  0.8375V
06:39:49  52.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:52  51.0'C  1000MHz  333MHz  01010000000000000000  0.8375V
06:39:55  53.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:39:58  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:40:01  55.0'C  1500MHz  500MHz  01010000000000000000  0.8375V <<<
06:40:04  54.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:40:07  55.0'C  1500MHz  500MHz  01010000000000000000  0.8375V <<<
Time       Temp     CPU     Core         Health           Vcore
06:40:10  55.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:40:13  55.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:40:16  57.0'C  1500MHz  500MHz  01010000000000000000  0.8375V <<<
06:40:19  57.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:40:22  57.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:40:25  56.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:40:28  57.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:40:31  58.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:40:34  57.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:40:37  57.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
06:40:40  59.0'C  1500MHz  500MHz  01010000000000000000  0.8375V





The poll appears to be every 100000us from my quick glance at the code running on the VC4

Breaching the "soft temp" limit will;
-by default at 60C which is easily reached for a poorly cooled Pi3B+
-cause a throttle down from 1.4GHz to 1.2GHz

Set this in /boot/config.txt to raise the threshold: and/or improve the cooling NOTE: 3A+/3B+ only?


temp_soft_limit=70







############## random observation dude
When scaling_governor is set to "performance", scaling_cur_freq returns correctly 1.4 GHz
When scaling_governor is set to "powersave", scaling_cur_freq returns correctly 600 MHz
When scaling_governor is set to "ondemand", scaling_cur_freq jumps between 600 and 1.4 GHz






https://www.raspberrypi.org/documentation/configuration/config-txt/overclocking.md
Changing core_freq in config.txt is not supported on the Pi 4, any change from the default will almost certainly cause a failure to boot.



#force_turbo=1 overrides this behaviour and forces maximum frequencies even when the ARM cores are not busy ondemandonly?


never_over_voltage
Sets a bit in the OTP memory (one time programmable) that prevents the device from being overvoltaged. This is intended to lock the device down so the warranty bit cannot be set either inadvertently or maliciously by using an invalid overvoltage.



Most overclocking issues show up immediately with a failure to boot. If this occurs, hold down the shift key during the next boot. This will temporarily disable all overclocking, allowing you to boot successfully and then edit your settings.







LLL




























WARNINGTHISWILLCORRUPTSDCARDEXT4() {




for nuM in 0 1 2 3 7; do #for nuM in 0 1 2 3 7; do
	case "$nuM" in
		0)
			echo -n "mainlcd"
		;;
		1)
			echo -n "secondlcd"
		;;
		2)
			echo -n "hdmi0"
		;;
		3)
			echo -n "composite"
		;;
		7)
			echo -n "hdmi1"
		;;
		*)
			echo -n "unknown"
		;;
		esac
	vcgencmd display_power -1 $nuM
done

exit 0
}

stacktraceathdmi() {
	cat <<'TTT'
[root@dca632 /usbstick 55°]# c[112478.705033] ------------[ cut here ]------------
[112478.709748] Firmware transaction timeout
[112478.709792] WARNING: CPU: 2 PID: 3481 at drivers/firmware/raspberrypi.c:63 rpi_firmware_transaction+0xa8/0xd0
[112478.723779] Modules linked in: qcserial pppoe ppp_async option l2tp_ppp cdc_mbim brcmfmac usb_wwan sr9700 rndis_host qmi_wwan pppox
 ppp_generic iscsi_tcp ipt_REJECT huawei_cdc_ncm ftdi_sio dm9601 cfg80211 cdc_ncm cdc_ether ax88179_178a xt_time xt_tcpudp xt_tcpmss xt
_statistic xt_state xt_recent xt_quota2 xt_quota xt_pkttype xt_owner xt_nat xt_multiport xt_mark xt_mac xt_limit xt_length xt_hl xt_hel
per xt_hashlimit xt_geoip xt_ecn xt_dscp xt_conntrack xt_connmark xt_connlimit xt_connbytes xt_comment xt_addrtype xt_TCPMSS xt_REDIREC
T xt_MASQUERADE xt_LOG xt_HL xt_FLOWOFFLOAD xt_DSCP xt_CT xt_CLASSIFY wireguard usbserial usbnet usbhid ums_usbat ums_sddr55 ums_sddr09
 ums_karma ums_jumpshot ums_isd200 ums_freecom ums_datafab ums_cypress ums_alauda slhc sch_cake r8152 pegasus nf_reject_ipv4 nf_log_ipv
4 nf_flow_table_hw nf_flow_table nf_conntrack_rtcache nf_conntrack_netlink nf_conncount macvlan libiscsi_tcp libiscsi iptable_raw iptab
le_nat iptable_mangle iptable_filter ipt_ECN ip6table_raw
[112478.723864]  ip_tables hid_generic exfat crc_ccitt compat cdc_wdm brcmutil fuse sch_teql sch_sfq sch_red sch_prio sch_pie sch_multi
q sch_gred sch_fq sch_dsmark sch_codel em_text em_nbyte em_meta em_cmp act_simple act_police act_pedit act_ipt act_gact act_csum libcrc
32c act_ctinfo sch_tbf sch_ingress sch_htb sch_hfsc em_u32 cls_u32 cls_tcindex cls_route cls_matchall cls_fw cls_flow cls_basic act_skb
edit act_mirred snd_bcm2835(C) hid evdev usb_f_ecm u_ether libcomposite ledtrig_usbport ledtrig_oneshot ledtrig_heartbeat ledtrig_gpio 
cryptodev xt_set ip_set_list_set ip_set_hash_netportnet ip_set_hash_netport ip_set_hash_netnet ip_set_hash_netiface ip_set_hash_net ip_
set_hash_mac ip_set_hash_ipportnet ip_set_hash_ipportip ip_set_hash_ipport ip_set_hash_ipmark ip_set_hash_ip ip_set_bitmap_port ip_set_
bitmap_ipmac ip_set_bitmap_ip ip_set nfnetlink ip6table_nat nf_nat nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 ip6t_NPT ip6t_rt ip6t_mh 
ip6t_ipv6header ip6t_hbh ip6t_frag ip6t_eui64 ip6t_ah
[112478.811119]  nf_log_ipv6 nf_log_common ip6table_mangle ip6table_filter ip6_tables ip6t_REJECT x_tables nf_reject_ipv6 ip6_gre ip_gr
e gre ifb dummy sit l2tp_netlink l2tp_core udp_tunnel ip6_udp_tunnel ipip ip6_tunnel tunnel6 tunnel4 ip_tunnel veth tun snd_rawmidi snd
_seq_device snd_pcm_oss snd_pcm_dmaengine snd_pcm snd_timer snd_mixer_oss snd_hwdep snd_compress snd soundcore nls_utf8 crypto_user alg
if_skcipher algif_rng algif_hash algif_aead af_alg sha1_generic md5 ghash_generic gf128mul gcm des_generic libdes cmac ccm authenc cryp
to_acompress vfat fat nls_iso8859_1 nls_cp437 dwc2 uhci_hcd ohci_platform ohci_hcd ledtrig_transient fsl_mph_dr_of ehci_platform ehci_f
sl ehci_hcd gpio_button_hotplug udc_core
[112478.960273] CPU: 2 PID: 3481 Comm: kworker/2:2 Tainted: G         C        5.4.87 #0
[112478.968093] Hardware name: Raspberry Pi 4 Model B Rev 1.1 (DT)
[112478.974010] Workqueue: events dbs_work_handler
[112478.978533] pstate: 60400005 (nZCv daif +PAN -UAO)
[112478.983402] pc : rpi_firmware_transaction+0xa8/0xd0
[112478.988357] lr : rpi_firmware_transaction+0xa8/0xd0
[112478.993311] sp : ffffffc0172c3a10
[112478.996702] x29: ffffffc0172c3a10 x28: 0000000000000000 
[112479.002092] x27: ffffff80783a8c38 x26: ffffff807fb90098 
[112479.007483] x25: ffffffc010b59008 x24: 0000000000001000 
[112479.012872] x23: ffffff807948a580 x22: ffffff807d2b8280 
[112479.018262] x21: ffffff807d2b8280 x20: 00000000ffffff92 
[112479.023651] x19: ffffffc010a0d378 x18: 0000000000000000 
[112479.029041] x17: 0000000000000000 x16: 0000000000000000 
[112479.034430] x15: 0000000000000000 x14: ffffffc010a33ba2 
[112479.039819] x13: 0000000000002934 x12: ffffffc010a33000 
[112479.045208] x11: ffffffc0109d7000 x10: 0000000000000010 
[112479.050597] x9 : ffffffc0172c3a10 x8 : 6361736e61727420 
[112479.055987] x7 : 657261776d726946 x6 : ffffffc010a3323c 
[112479.061376] x5 : 00ffffffffffffff x4 : 0000000000000000 
[112479.066765] x3 : 0000000000000000 x2 : 00000000ffffffff 
[112479.072154] x1 : ffffffc06f20b000 x0 : 000000000000001c 
[112479.077543] Call trace:
[112479.080068]  rpi_firmware_transaction+0xa8/0xd0
[112479.084676]  rpi_firmware_property_list+0xa0/0x140
[112479.089544]  rpi_firmware_property+0x6c/0x100
[112479.093982]  raspberrypi_fw_set_rate+0x40/0xa0
[112479.098504]  raspberrypi_fw_pll_set_rate+0x10/0x18
[112479.103372]  clk_change_rate+0x144/0x290
[112479.107371]  clk_core_set_rate_nolock+0x170/0x1a8
[112479.112152]  clk_set_rate+0x34/0xa0
[112479.115720]  dev_pm_opp_set_rate+0x308/0x498
[112479.120067]  set_target+0x3c/0x80
[112479.123460]  __cpufreq_driver_target+0x164/0x570
[112479.128155]  od_dbs_update+0xb8/0x190
[112479.131894]  dbs_work_handler+0x3c/0x70
[112479.135809]  process_one_work+0x1ec/0x378
[112479.139896]  worker_thread+0x48/0x4d0
[112479.143637]  kthread+0x120/0x128
[112479.146944]  ret_from_fork+0x10/0x1c
[112479.150596] ---[ end trace e561a29cf6f48a4e ]---
[112479.155321] raspberrypi-clk firmware-clocks: Failed to change pllb frequency: -110
[112480.800601] cpu cpu0: dev_pm_opp_set_rate: failed to find current OPP for freq 9223372036854775698 (-34)
[112481.841119] raspberrypi-clk firmware-clocks: Failed to change pllb frequency: -110
[112482.876995] cpu cpu0: dev_pm_opp_set_rate: failed to find current OPP for freq 9223372036854775698 (-34)
[112483.889160] raspberrypi-clk firmware-clocks: Failed to change pllb frequency: -110
[112485.840837] cpu cpu0: dev_pm_opp_set_rate: failed to find current OPP for freq 9223372036854775698 (-34)
[112486.865193] raspberrypi-clk firmware-clocks: Failed to change pllb frequency: -110
TTT
}






























####################################################################################
#15:36:50  59.0'C  1500MHz  500MHz  00000000000000000000  0.8375V
#15:36:54  60.0'C  1500MHz  500MHz  00000000000000000000  0.8375V
#15:36:57  61.0'C  1500MHz  500MHz  00000000000000000000  0.8375V
#15:37:00  57.0'C   600MHz  200MHz  01010000000000000101  0.8350V
####################################################################################
#NPROC:4 RUNSSLBENCH:1
#starting opensslbench with 4 cores
#Time       Temp     CPU     Core         Health           Vcore
#15:46:22  50.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
#15:46:26  52.0'C   600MHz  200MHz  01010000000000000101  0.8350V
#15:46:29  55.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
#15:46:32  55.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
####################################################################################





Anewphase() {



#Health not populating? use :-5@if?


HealthHex=$(vcgencmd get_throttled | cut -f2 -d=)

Health=$(perl -e "printf \"%19b\n\", $(vcgencmd get_throttled | cut -f2 -d=)")
echo "$HealthHex $Health"; sleep 1 #1010000000000000000



#but 19 listed as max 0 as min?
#   1   0   1   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0
#   19  18  17 16  15  14  13  12  11  10  9    8   7  6   5   4   3   2    1

#    0   1   0   1                                           1    0    1
#        18     16                                           2    1    0

#   0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18 #WRONG
#the bits 19-16 are 0101, so throttling has occurred (bit 18) and undervolt has occurred (bit 16)
##################################################### backwards
#Hex 			5 0 0 0 0
#Binary 		0101 0000 0000 0000 0000
#Bit#---- 		1111 1111 1100 0000 0000 
#----------- 9876 5432 1098 7654 3210 
#-------------------^--- Bit 16 is on - Been under voltage (at least once)
#---------------^------- Bit 18 is on - Been throttled (at least once)
#(Note: since bits 0-3 are zero, the Pi is not currently UV or throttled)


#pretty sure thats 18 and 16 throt and under HAS OCCURRED SEE BENCH BELOW for CURRENTLY ACTIVE
# WHICH is 0 and 2 under detected + currently throttled











#echo "SETXZVALS HEALTHRAW: $HEALTH"; set -x; sleep 2
#perl -e "printf \"%19b\n\", $(vcgencmd get_throttled | cut -f2 -d=)"




#vcgencmd get_throttled | cut -f2 -d=
#vcgencmd get_throttled | cut -f2 -d=
#vcgencmd get_throttled | cut -f2 -d=




#Health=$(perl -e "printf \"%19b\n\", $(vcgencmd get_throttled | cut -f2 -d=)")
#echo "SETXZVALS HEALTHRAW: $HEALTH"; set -x; sleep 2


#sleep 3
#exit 0













###################################################################### REPORTS
Hbit19=$(echo $Health | cut -c1)
#echo "19:$Hbit19" #19 "first" #Hbit19=$(echo $Health | cut -c19)
if [ "$Hbit19" -eq 1 ]; then echo "Soft temp limit has occurred"; fi

Hbit18=$(echo $Health | cut -c2)
#echo "18:$Hbit18" #| 18 | Throttling has occurred |
if [ "$Hbit18" -eq 1 ]; then echo "Throttle has occurred"; fi


Hbit17=$(echo $Health | cut -c3)
#echo "17:$Hbit17" #| 17 | Arm frequency capped has occurred |
if [ "$Hbit17" -eq 1 ]; then echo "Arm frequency capped has occurred"; fi

Hbit16=$(echo $Health | cut -c4)
#echo "16:$Hbit16" #| 16 | Under-voltage has occurred |
if [ "$Hbit16" -eq 1 ]; then echo "Under-voltage has occurred"; fi


################################################################### DYNAMICAKACOUNTERS
Hbit1=$(echo $Health | cut -c19)
if [ "$Hbit1" -eq 1 ]; then echo "Under-voltage detected"; fi
#if [ "$Hbit1" -eq 0 ]; then echo "Under-voltage detectedno"; fi

Hbit2=$(echo $Health | cut -c18)
if [ "$Hbit2" -eq 1 ]; then echo "Frequency Capped"; fi
#if [ "$Hbit2" -eq 0 ]; then echo "Frequency Not Capped"; fi

Hbit3=$(echo $Health | cut -c17)
if [ "$Hbit3" -eq 1 ]; then echo "Currently throttled"; fi
#if [ "$Hbit3" -eq 0 ]; then echo "Not Currently throttled"; fi

Hbit4=$(echo $Health | cut -c16)
if [ "$Hbit4" -eq 1 ]; then echo "Soft temp limit active"; fi
#if [ "$Hbit4" -eq 0 ]; then echo "Soft temp limit notactive"; fi
#exit 0


}




##########################################
##########################################
##########################################
##########################################
##########################################


HOWWEGET_ZEROINSECONDVAR() {
HealthHex="0x00000"
echo "$HealthHex"
Health=$(perl -e "printf \"%19b\n\", $HealthHex")
echo "$Health"
}

#echo "SETXZVALS HEALTHRAW: $HEALTH"; set -x; sleep 2
#perl -e "printf \"%19b\n\", $(vcgencmd get_throttled | cut -f2 -d=)"
#vcgencmd get_throttled | cut -f2 -d=
#Health=$(perl -e "printf \"%19b\n\", $(vcgencmd get_throttled | cut -f2 -d=)")
#echo "SETXZVALS HEALTHRAW: $HEALTH"; set -x; sleep 2
#sleep 3
#exit 0




#@@@NPROC is 2 then 4
#for P in `seq 1 20`; do
#	NPROC=${NPROC:-2}
#	echo "NPROC:$NPROC RUNSSLBENCH:$RUNSSLBENCH"
	#### newphase
#done
#sleep 2
#exit 0







#echo "(while [ ! -z "$(ps w | sed 's!^[[:space:]]!!g' | grep "^$$ ")" ]; do sleep 3; done; $0 cleanup) &"
#(while [ ! -z "$(ps w | sed 's!^[[:space:]]!!g' | grep "^$$ ")" ]; do sleep 3; done; $0 cleanup) &


#echo "###########HMM" #NOPE pgrep $$
#echo $$
#ps w | grep -v grep | grep $0
#echo "###########HMM"
#sleep 2
#pgrep -f $0

#echo "(while [ ! -z "$(pgrep -f $0)" ]; do sleep 3; done; $0 cleanup) &"
#(while [ ! -z "$(pgrep -f $0)" ]; do sleep 3; done; $0 cleanup) &

#####echo "(while [ ! -z "$(pgrep $sPID)" ]; do sleep 3; done; $0 cleanup) &"
######echo "(while [ ! -z "$(pidof $sPID)" ]; do sleep 3; done; $0 cleanup) &"
######echo "(while [ ! -z "$(pidof $0)" ]; do sleep 3; done; $0 cleanup) &"










#  881  echo -n 230 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
#  882  ./rpi-throttlewatch.sh 
#  883  echo -n 57 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
#20:34:08  48.0'C  1500MHz  500MHz  01010000000000000000  0.8375V
#20:34:11  48.0'C  1000MHz  333MHz  01010000000000000000  0.8375V
#>>>20:34:14  47.0'C  1000MHz  250MHz  01010000000000000000  0.8375V
#20:34:17  48.0'C  1000MHz  333MHz  01010000000000000000  0.8375V
#20:34:20  47.0'C  1000MHz  333MHz  01010000000000000000  0.8375V










#cat /sys/devices/system/cpu/cpufreq/policy0/stats/time_in_state | sed 's! !:!g'








