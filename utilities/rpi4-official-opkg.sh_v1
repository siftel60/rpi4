#!/bin/sh





getopkgurlpath() {


	local repoFs="${1}"
	local repoN="${2}"

	case "$repoFs" in
		all)	#@@@ grep -q src .conf +filename/s
			repoFs="/etc/opkg/distfeeds.conf /etc/opkg/customfeeds.conf"
		;;
		custom)
			repoFs="/etc/opkg/customfeeds.conf"
		;;
		official)
			repoFs="/etc/opkg/distfeeds.conf"
		;;
		*)
			repoFs="/etc/opkg/distfeeds.conf /etc/opkg/customfeeds.conf"
		;;
	esac



	########################################shifts&&||grep -q
	#grep -q uniq "${*}" && ONERESULT=1
	#grep -q enabled "${*}" && ENABLEDONLY=1


	case "${repoN}" in
		core)
			#echo "cat $repoFs 2>/dev/null | grep core | cut -d' ' -f3 | cut -d'/' -f4-"
			#RESULT=$()
			cat $repoFs 2>/dev/null | grep core | cut -d' ' -f3 | cut -d'/' -f4-
		;;
		luci)
			cat $repoFs 2>/dev/null | grep luci | cut -d' ' -f3 | cut -d'/' -f4-
		;;
	esac

#if [ ! -z "$RESULT" ]; then


return 0

}





opkgofficial() {

##################################### FAILSAFESJUSTINCASE
oDN="${oDN:-"downloads.openwrt.org"}"
oH="${oH:-"http://"}"


oS="${oS:-"${oH}${oDN}"}" #thisonemaybelater
#echo "DBG: oS: $oS"




	case "$1" in
	start)

O_BASEPATH=$(dirname $(getopkgurlpath official core))
O_PPATH=$(dirname $(getopkgurlpath official luci))
#VALIDATETHESE :-xyz

. /etc/openwrt_release
KERNEL="$(opkg list-installed kernel)"
O_KPATH="${O_BASEPATH}/kmods/${KERNEL##* }"




	if mount | grep -q '/etc/opkg/distfeeds.conf' && mount | grep -q '/etc/opkg/customfeeds.conf'; then return 0; fi

#WRONGupdatedidnotRETfailtoo src/gz openwrt_base ${oS}/${O_BASEPATH}/base
#NOTE thisworkedverywellforcommunitybuildAKA->NOBASE



cat <<LLL > /tmp/distfeeds.conf
src/gz openwrt_base ${oS}/${O_PPATH}/base
src/gz openwrt_freifunk ${oS}/${O_PPATH}/freifunk
src/gz openwrt_luci ${oS}/${O_PPATH}/luci
src/gz openwrt_packages ${oS}/${O_PPATH}/packages
src/gz openwrt_routing ${oS}/${O_PPATH}/routing
src/gz openwrt_telephony ${oS}/${O_PPATH}/telephony
LLL



cat <<LLL >> /tmp/distfeeds.conf
src/gz openwrt_kmods ${oS}/${O_KPATH}
LLL



if [ ! -z "$DEBUG" ]; then
	echo "cp /tmp/distfeeds.conf /tmp/DIST"
	cp /tmp/distfeeds.conf /tmp/DIST
fi



if [ ! -z "$DOCORE" ]; then #HMMWAS-ON rpi4
	echo "src/gz openwrt_core ${oS}/${O_BASEPATH}/packages" >> /tmp/distfeeds.conf
fi

#echo "CURRENTBASE: src/gz openwrt_base ${oS}/${O_BASEPATH}/base"



cat <<'LLL' > /tmp/customfeeds.conf
#
LLL



#possible rm -rf /tmp/opkg-lists/


rm -rf /tmp/opkg-lists/. 2>/dev/null
rm -rf /var/opkg-lists/. 2>/dev/null

mount -o bind /tmp/distfeeds.conf /etc/opkg/distfeeds.conf
mount -o bind /tmp/customfeeds.conf /etc/opkg/customfeeds.conf



#MASQDEBUG=1
#MASQvariant=


	#if ! opkg update; then
	if ! opkg update 1>/dev/null 2>/dev/null; then
		MASQmsg="$MASQmsg opkgupdatefailed"
		OPKGUPDfail=1
		#@@@onwhatrepo/s
	fi

	;;
	stop)
		while [ ! -z "$(mount | grep feeds | cut -d' ' -f3)" ]; do
			umount $(mount | grep feeds | cut -d' ' -f3 | head -n1) 1>/dev/null 2>/dev/null
		done; rm /tmp/distfeeds.conf 2>/dev/null; rm /tmp/customfeeds.conf 2>/dev/null
	;;
	esac

}






































parseallparams() {

#set -x

while [ "$#" -gt 0 ]; do
    case "${1}" in
    help) usage; exit 0; ;;
    "-Q") RCSLEEP=0; shift 1; ;;
    "-v")
	    VERBOSE=2
	    shift 1
	    ;;
    "-D") DEBUG=1
	    shift 1
	    ;;
    "-Q") VERBOSE=0; shift 1; ;;


    #SERVER) oDN="${2}"; shift 2; ;;

    http|https) oH="${1}://"; shift 1; ;;


    start) sACTION="start"; shift 1; ;;
    stop) sACTION="stop"; shift 1; ;;
    core) DOCORE=1; shift 1; ;;
    force) FORCE="force"; shift 1; ;;
    mitigate) MITIGATE=1; shift 1; ;;
    status) sACTION="${1}"; shift 1; ;;
    backup) :; shift 1; ;; #ipsetsubcommand ignore here or alter *) logic
    *)
    	OPKGOPTS="$OPKGOPTS ${1}"
	shift 1
	;; #echo "$0 [stable|current|check] ?:$1"; exit 0
    esac #if [ -f
done

}
################################################################################################
#sACTION="${1:-start}"
#echL "####################################################### $sACTION@$CNAME" msg; sleep ${RCSLEEP:-0}







usage() {
cat <<LLL

	$0 <opkg-cmds> [extraopts]

		core			enable core
		start			mount -o and update (use stop when done)



	$0 list-upgradable		#starts, updates, runs-cmd(nocore), stops
	$0 upgrade modemmanager
	$0 start core; $0 list-upgradable; $0 stop


	$0 mitigate dnsmasq-full odhcp6c netifd
	$0 mitigate simple-adblock dnsmasq-full
LLL
}






##################### set trap for cleanup ######### BREAKs start
#trap '
#	opkgofficial stop
#' 0 1 2 3 15







ALLPARAMS=${*}
parseallparams ${ALLPARAMS}


#echo "DBG OPKGOPTS: $OPKGOPTS"
#echo "DBG sACTION: $sACTION"




#set -x


#set -x










V() {

if [ ! -z "$VERBOSE" ]; then
	echo "${1}" >&2
fi

}










#oDN_DEFAULT="downloads.openwrt.org"
oDN_DEFAULT="downloads.cdn.openwrt.org"
oH_DEFAULT="http://"


oDN="${oDN:-"$oDN_DEFAULT"}"
oH="${oH:-"${oH_DEFAULT}"}"
oS="${oS:-"${oH}${oDN}"}"




V "server: ${oS}" #echo "oH: ${oH}"
#exit 0





#DOCORE=1








#if ! grep -q SNAPSHOT /etc/os-release; then echo "$0 snapshot-only" && exit 0; fi

#MODELf=$(cat /tmp/sysinfo/board_name)
#case "$MODELf" in
#	*"4-model-b"*|*"rpi4"*) :; ;;
#	*) echo "model-unsupported: $MODELf"; exit 0; ;;
#esac





V "enable+update official repos"
opkgofficial start
if [ "$sACTION" = "start" ]; then
	exit 0
elif [ "$sACTION" = "stop" ]; then
	V "stop official repos"
	opkgofficial stop; exit 0

else

	#cat /tmp/distfeeds.conf | cut -d' ' -f2; sleep 2




	if [ ! -z "$MITIGATE" ]; then

		for pOPT in $OPKGOPTS; do
			V "opkgcmd: /bin/opkg list-upgradable | grep -q ${pOPT}"
			if /bin/opkg list-upgradable | grep -q "^${pOPT} "; then
				echo "$pOPT has-fixes: $(/bin/opkg list-upgradable | grep "^${pOPT}")"
				/bin/opkg upgrade "${pOPT}" && touch /tmp/.mitigated #1> 2> + reboot
			else
				echo "$pOPT no-fixes"
			fi
		done

	else
		V "opkgcmd: /bin/opkg ${OPKGOPTS}"
		/bin/opkg ${OPKGOPTS}
	fi

fi







V "stop official repos"
opkgofficial stop






exit 0







