#!/bin/sh




################################[root@dca632 /usbstick 50°]# cat /etc/crontabs/root 
#59 * * * * /bin/mitigate.sh
#/etc/init.d/cron restart
#cp mitigate.sh /root/tasks/daily/
############################ Reboot at 4:30am every day Note: To avoid infinite reboot loop, wait 70 seconds
## and touch a file in /etc so clock will be set properly to 4:31 on reboot before cron starts.
#30 4 * * * sleep 70 && touch /etc/banner && reboot












#curl -sSL https://raw.githubusercontent.com/wulfy23/rpi4/master/utilities/dnsmasqfix.sh > /tmp/dnsmasqfix.sh; chmod +x /tmp/dnsmasqfix.sh; /tmp/dnsmasqfix.sh








TMPd="/tmp"


WGET="wget --no-parent -q -nd -l1 -nv --show-progress "
WGETs="wget --no-parent -q -nd -l1 -nv"
Gbase="https://raw.github.com/wulfy23/rpi4/master/utilities"


SN=$(basename $0)







fails() {
    echo "$1" && exit 1
}










handleallparams() {

	#local FN="handleallparams"
	#echo "$FN> 1 $1"; echo "$FN> 2 $2"; echo "$FN> all $@"; sleep 3

	set -- "${@}"

	while [ "$#" -gt 0 ]; do

		#echo "param: $1"

		case "$1" in
		--help|-h|help) #--help|-h|help)
			usage && exit
		;;
		demo)
			DEMO=1
			cmdParam="$cmdParam $1"
		;;
		-f|force)
			FORCE=1
			cmdParam="$cmdParam $1"
		;;
		-Q)
			QUICK=1
			cmdParam="$cmdParam $1"
		;;
		-D)
			DEBUG=1
			cmdParam="$cmdParam $1"
		;;
		-v)
			VERBOSE=1
			cmdParam="$cmdParam $1"
		;;
		-N)
			NOACTION=1 #notusedinthisscript
			cmdParam="$cmdParam $1"
		;;
		-S)
			ISSCRIPT=1
			cmdParam="$cmdParam $1"
		;;
		#simple) sACTION="${1}"; ;;
		-*) 
			cmdParam="$cmdParam $1"
		;;
		*)
			customParam="$customParam $1"
		;;
		esac

		shift
	done

}











usage() {


cat <<VVV

	$0

		##################################### cmd params
		--help
		-[X]

		##################################### wrapperparams
		-h|help
		-D			debug
		-Q			quick
		-v			verbose

		-S			ISSCRIPT -> logger
		-N			noaction (printcommands)

		cron


		demo			fakeoldstuff
	
		-f			force (wip->redownloadwrappedfileandrmflagfiles)
VVV

}











#@SN works here but not in wrapped script

V() {

	if [ ! -z "$VERBOSE" ] || [ ! -z "$DEBUG" ]; then #if [ ! -z "$VERBOSE" ]; then
		if [ ! -z "$ISSCRIPT" ]; then
			logger $SN "V: ${*}"
		else

			echo "$SN-V: ${*}" >&2
		fi
    		
		if [ ! -z "$QUICK" ]; then sleep 1; fi
	fi

}




O() {
	if [ ! -z "$ISSCRIPT" ]; then
		logger $SN "${*}"
	else
		#echo "${*}"
		echo "$SN> ${*}"
		echo "$SN-O-$Dy> ${*}" > /dev/console
	fi
	#if [ ! -z "$QUICK" ]; then sleep 1; fi
}










D() { #avoidusingthis@v||!-zDEBUG
	if [ ! -z "$DEBUG" ]; then
		if [ ! -z "$ISSCRIPT" ]; then
			logger $SN "D: ${*}"
		else
			echo "$SN-D: ${*}" #>&2
		fi
		if [ ! -z "$QUICK" ]; then sleep 1; fi
	fi
}









####### unused-ish
####### unused-ish
####### unused-ish
Dy=$(date +%Y%m%d-%H%M)
OUTFILE="/tmp/$(basename $0)-result-$Dy"
####### unused-ish
####### unused-ish
####### unused-ish






#set -x
ALLPARAMS="${*}" #ALTERNATE-ASSIGN-PROPERPARAMS@PROBABLE dump all to file and use 'stats' post dump
handleallparams ${*}
#echo "      allparams: $ALLPARAMS"; echo "    customParam: $customParam"; echo "       cmdParam: $cmdParam"

D "cmdParam=\"$cmdParam\" customParam=\"$customParam\""

#exit 0








if [ ! -z "$ISSCRIPT" ]; then
	QUICK=1
fi









############################## get-the-github-realscript>tmp
Bname="run-mitigate.sh"
BFULL="${TMPd}/$Bname"


#@@@?> FORCE+rmalldated rm /tmp/$(basename $BFULL)-*
#BREAKS datedff #rm "${BFULL:-/tmp/rar}" 2>/dev/null #everyrungetagain


#if [ ! -f "$BFULL" ]; then
   
    if [ ! -f /tmp/$(basename $BFULL)-$(date +%Y%m%d%H) ]; then
    	V "Download: $Bname"

    	$WGETs -O $BFULL "${Gbase}/$Bname" || OOPSIE=1
   	if [ ! -z "$OOPSIE" ]; then
	    	rm $BFULL 2>/dev/null
		fails "dlprob"
    	fi
    
    	chmod +x $BFULL
    	touch /tmp/$(basename $BFULL)-$(date +%Y%m%d%H)

    else
	    D "using cached $(basename $BFULL) $(date +%Y%m%d%H)"
    fi


#fi #$WGET -O /usr/sbin/$Bname "${Gbase}/$Bname" || fails "dlprob"
















if [ -z "$1" ]; then sACTION="simple"; fi
if [ "$sACTION" != "simple" ]; then
	while [ "$#" -gt 0 ]; do sACTION="$sACTION $1"; shift; done
fi




#DEBUG=1
if [ -n "$DEBUG" ]; then
	echo "             fullcmd: $BFULL"
	echo "        OUTFILE(pfx): $OUTFILE"
	echo "  sACTION(allparams): $sACTION"
fi
#exit 0



#set -x









#O "running mitigations..." #sh "$BFULL" #$customParam #sh "$BFULL" $cmdParam $customParam



#V echo "run> $BFULL"
D "sh \"$BFULL\" $cmdParam $customParam"












sh "$BFULL" $cmdParam $customParam
#########ORG sh "$BFULL" $cmdParam $customParam
#######$BFULL $cmdParam $customParam





exit 0













case "$sACTION" in
    *)
	echo "nosaction"
	;;
    nostop) :; ;;
esac





case "$sACTION" in
    simple)
	    :
	;;
esac







exit 0












#curl -sSL https://raw.githubusercontent.com/wulfy23/rpi4/master/utilities/mitigate.sh > /tmp/mitigate.sh; chmod +x /tmp/mitigate.sh; /tmp/mitigate.sh





#curl -sSL https://raw.githubusercontent.com/wulfy23/rpi4/master/utilities/mitigate.sh > /bin/mitigate.sh; chmod +x /bin/mitigate.sh; /bin/mitigate.sh









