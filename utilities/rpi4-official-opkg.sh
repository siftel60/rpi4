#!/bin/sh



#-l @ semi-perma


#if /bin/rpi4-official-opkg.sh list-upgradable | grep -q "^ABC "; then
#	/bin/rpi4-official-opkg.sh upgrade "ABC"
#fi





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
			cat $repoFs 2>/dev/null | grep core | cut -d' ' -f3 | cut -d'/' -f4- | head -n 1
			#@@@tail
		;;
		luci)
			cat $repoFs 2>/dev/null | grep luci | cut -d' ' -f3 | cut -d'/' -f4- | head -n 1
			#@@@tail
		;;
	esac

#if [ ! -z "$RESULT" ]; then


return 0

}







opkgofficial() {

	local FN="opkgofficial" #echo "STATIC-$FN-DBG-ON"; sleep 2; local DEBUG=1

	oDN="${oDN:-"downloads.openwrt.org"}"; oH="${oH:-"http://"}" ################## FAILSAFESJUSTINCASE
	oS="${oS:-"${oH}${oDN}"}" #echo "DBG: oS: $oS"


	case "$1" in
	start)
	
		if mount | grep -q '/etc/opkg/distfeeds.conf' && mount | grep -q '/etc/opkg/customfeeds.conf'; then
			V "start-called-tho-mounted@rerun?"
			return 0
		fi

		sanitycheck

		V "enable+update official repos: $REPOSEN_OFFICIAL"



		O_BASEPATH=$(dirname $(getopkgurlpath official core))
		O_PPATH=$(dirname $(getopkgurlpath official luci))

		#NEEDSTOHAPPENINMAIN||startonly@opkg kveronRERUN #. /etc/openwrt_release; KERNEL="$(opkg list-installed kernel)"
		. /etc/openwrt_release; KERNEL="$(opkg list-installed kernel)"
		O_KPATH="${O_BASEPATH}/kmods/${KERNEL##* }"







		#VALIDATETHESE :-xyz
		[ -z "${O_BASEPATH}" ] && exit 0
		[ -z "${O_PPATH}" ] && exit 0
		[ -z "${O_KPATH}" ] && exit 0 #@fails


	rm /tmp/distfeeds.conf 2>/dev/null

	for oREPOn in $REPOSEN_OFFICIAL; do

	case "$oREPOn" in
	*"base"*) #cat <<LLL !@> /tmp/distfeeds.conf
cat <<LLL >> /tmp/distfeeds.conf
src/gz openwrt_base ${oS}/${O_PPATH}/base
LLL
	;;
	
	*"luci"*)
cat <<LLL >> /tmp/distfeeds.conf
src/gz openwrt_luci ${oS}/${O_PPATH}/luci
LLL
	;;


	*"packages"*)
cat <<LLL >> /tmp/distfeeds.conf
src/gz openwrt_packages ${oS}/${O_PPATH}/packages
LLL
	;;


	*"routing"*)
cat <<LLL >> /tmp/distfeeds.conf
src/gz openwrt_routing ${oS}/${O_PPATH}/routing
LLL
	;;

	*"telephony"*)
cat <<LLL >> /tmp/distfeeds.conf
src/gz openwrt_telephony ${oS}/${O_PPATH}/telephony
LLL
	;;


	*"freifunk"*)
cat <<LLL >> /tmp/distfeeds.conf
src/gz openwrt_freifunk ${oS}/${O_PPATH}/freifunk
LLL
	;;
	
	*"kmods"*)
cat <<LLL >> /tmp/distfeeds.conf
src/gz openwrt_kmods ${oS}/${O_KPATH}
LLL
	;;

	#####################
	*"core"*)
	#echo "core @ wip DOCORE"
	#echo "COREHASfakeFAIL"; sleep 2; #set -x
#FAKE@TESTfailupdatehandling
#src/gz openwrt_core ${oS}/${O_BASEPATH}/pack
cat <<LLL >> /tmp/distfeeds.conf
src/gz openwrt_core ${oS}/${O_BASEPATH}/packages
LLL
	;;

	esac
	done #@oREPOn
	#WRONGupdatedidnotRETfailtoo src/gz openwrt_base ${oS}/${O_BASEPATH}/base #NOTE thisworkedforcommunitybuildAKA->NOBASE
#!!!WIP
#if [ ! -z "$DOCORE" ]; then #HMMWAS-ON rpi4  
#	echo "src/gz openwrt_core ${oS}/${O_BASEPATH}/packages" >> /tmp/distfeeds.conf
#fi



cat <<'LLL' > /tmp/customfeeds.conf
#
LLL









#cat <<LLL > /tmp/distfeeds.conf
#src/gz openwrt_base ${oS}/${O_PPATH}/base
#src/gz openwrt_luci ${oS}/${O_PPATH}/luci
#src/gz openwrt_packages ${oS}/${O_PPATH}/packages
#src/gz openwrt_routing ${oS}/${O_PPATH}/routing
#src/gz openwrt_telephony ${oS}/${O_PPATH}/telephony
#src/gz openwrt_freifunk ${oS}/${O_PPATH}/freifunk
#LLL


#cat <<LLL >> /tmp/distfeeds.conf
#src/gz openwrt_kmods ${oS}/${O_KPATH}
#LLL

################################################################ Enable kmods repository kmods-show-with-this-off@core->yes
##. /etc/openwrt_release
##KERNEL="$(opkg list-installed kernel)"
##cat << EOF >> /tmp/distfeeds.conf
##src/gz openwrt_kmods http://downloads.openwrt.org/\
##snapshots/targets/${DISTRIB_TARGET}/kmods/${KERNEL##* }
##EOF
#########################################################################################
##echo "snapshots/targets/${DISTRIB_TARGET}/kmods/${KERNEL##* }"
##https://downloads.openwrt.org/releases/19.07.6/targets/brcm2708/bcm2708/kmods/4.14.215-1-1e1f49421f1facff51a1411021c6d082/






	if [ ! -f /tmp/distfeeds.conf ]; then echo "oops no /tmp/distfeeds.conf" && exit 0; fi




	cp /tmp/distfeeds.conf /tmp/DIST
	if [ ! -z "$DEBUG" ]; then
		#echo "cp /tmp/distfeeds.conf /tmp/DIST"
		cp /tmp/distfeeds.conf /tmp/DIST
		echo "########### cat /tmp/distfeeds.conf /tmp/DIST"
		cat /tmp/distfeeds.conf
		sleep 3
	fi #cp /tmp/distfeeds.conf /tmp/DIST3





if [ ! -z "$DOTMPLISTDIR" ]; then
	V "rm -rf ${lists_dir:-"/var/opkg-lists/*"}"
	rm -rf ${lists_dir:-"/var/opkg-lists/*"} 2>/dev/null
else
	V "DOTMPLISTDIR-Z no->: rm -rf ${lists_dir:-"/var/opkg-lists/*"}"
fi #rm -rf /tmp/opkg-lists/. 2>/dev/null; rm -rf /var/opkg-lists/. 2>/dev/null



	V "mount -o bind /tmp/distfeeds.conf /etc/opkg/distfeeds.conf"
	mount -o bind /tmp/distfeeds.conf /etc/opkg/distfeeds.conf


	V "mount -o bind /tmp/customfeeds.conf /etc/opkg/customfeeds.conf"
	mount -o bind /tmp/customfeeds.conf /etc/opkg/customfeeds.conf




	##################################################TMPdO="/tmp/$(basename $0)"; mkdir -p $TMPdO
	#######if ! opkg update 1>/dev/null 2>/dev/null; then
	TMPfOU="${TMPdO}/opkg.update.out" #!PREFIX!
	OUD=$(date +%Y%m%d%H%M)


	V "opkg update 1>${TMPfOU}.stdout.${OUD} 2>${TMPfOU}.stderr.${OUD}"
	if ! opkg update 1>${TMPfOU}.stdout.${OUD} 2>${TMPfOU}.stderr.${OUD}; then

		V "opkgupdatefailed" #V "opkgupdatefailed"; V "opkgupdatefailed"
		OPKGUPDfail=1

		if grep -q 'Failed to download the package list' ${TMPfOU}.stdout.${OUD}; then
			
			#~REPOfails=1 #@@@opkglogparse() { TBA #@?? MASQmsg="$MASQmsg opkgupdatefailed"
			
			echo "################## bad-repo-url/s-or-down" #@$(appendget opkglogbadrepos)
			cat ${TMPfOU}.stdout.${OUD} | grep 'Failed to download the package list' | \
				sed 's!^*** Failed to download the package list from !!g' #@@@whilereadgrepname.conf
		fi

		#V||VS echo "sleep 3"; sleep 3
	fi #@@@onwhatrepo/s


	if [ ! -z "$DEBUG" ]; then
		echo "############## $FN> post-update-debug"
		find /tmp/opkg-lists/ | grep '\.sig$'
		#ls -1 /tmp/opkg-lists/
		#cat /tmp/opkg-lists/*.sig
	

		echo "########### cat ${TMPfOU}.stdout.${OUD}"; cat ${TMPfOU}.stdout.${OUD}
		echo "########### cat ${TMPfOU}.stderr.${OUD}"; cat "${TMPfOU}.stderr.${OUD}"
		sleep 2
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
    nostop) NOSTOP="1"; shift 1; ;;
    force) FORCE="force"; shift 1; ;;
    mitigate) MITIGATE=1; shift 1; ;;
    

    #@-RO core) DOCORE=1; shift 1; ;;
    -RO) #REPOSEN_OFFICIAL="${2}"; shift 2; 
	shift
	while [ -z "$NOrMATCH" ]; do #echo "DBG-ADD-RO: $1"; #exit 0 #@"a b" nowork
	case "${1}" in
	 luci|kmods|base|core|packages|routing|telephony|freifunk) REPOSEN_OFFICIAL="${REPOSEN_OFFICIAL} $1"; shift; ;;
	*) NOrMATCH=1; ;;
	esac
	done
	#echo "DBGPOSTPARSE:	REPOSEN_OFFICIAL: ${REPOSEN_OFFICIAL}"

     ;; #MUSTBEINQUOTES
    




    #status) sACTION="${1}"; shift 1; ;; #BREAKSOPKGstatus #NOPE STATUS) sACTION="${1}"; shift 1; ;; #BREAKSOPKGstatus
    STATUS) sACTION="status"; shift 1; ;; #NB: added main-if-prestart+exit


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

		start			mount -o and update (use stop when done)



		nostop			after start more calls to come so skip stop
					technically dont need start with this
					unless alternate repos need to be mounted




	$0 list-upgradable		#starts, updates, runs-cmd(nocore), stops
	$0 upgrade modemmanager
	$0 start core; $0 list-upgradable; $0 stop


	$0 mitigate dnsmasq-full odhcp6c netifd
	$0 mitigate simple-adblock dnsmasq-full




	-RO "luci core"			#repos enabled official (default(now)isnocore)
					#OLD core			enable core



time ./rpi4-official-opkg.sh update -v nostop





NOTE: dont forget to run opkg update again before using the normal build repos
NOTE: there are a few packages for which some of the base files are modified
      (mostly at hotplug vpnpolicy simple-adblock shutup -> cosmetic )
      upgrading said/random packages may effect some build functions




#NB-QUOTES-MAKENODIFFERENCE
#NB-QUOTES-MAKENODIFFERENCE
#NB-QUOTES-MAKENODIFFERENCE
./rpi4-official-opkg.sh status dnsmasq-full -v -RO "luci" -v
./rpi4-official-opkg.sh status dnsmasq-full -RO 'luci kmods core'



[root@dca632 /usbstick 50°]# ./rpi4-official-opkg.sh files iftop -RO luci
###########Collected errors:  * opkg_files_cmd: Package iftop not installed.


[root@dca632 /usbstick 49°]# ./rpi4-official-opkg.sh list iftop -RO luci
[root@dca632 /usbstick 50°]# ./rpi4-official-opkg.sh list iftop -RO base
[root@dca632 /usbstick 50°]# ./rpi4-official-opkg.sh list iftop -RO core
[root@dca632 /usbstick 49°]# ./rpi4-official-opkg.sh list iftop -RO packages
iftop - 2018-10-03-77901c8c-2 - iftop does for network usage what top(1) does for CPU usage. It
 listens to network traffic on a named interface and displays a
 table of current bandwidth usage by pairs of hosts. Handy for
 answering the question 'why is our ADSL link so slow?'.




LLL
}






##################### set trap for cleanup ######### BREAKs start
#trap '
#	opkgofficial stop
#' 0 1 2 3 15




ALLPARAMS=${*}
parseallparams ${ALLPARAMS}


#echo "DBG OPKGOPTS: $OPKGOPTS"; echo "DBG sACTION: $sACTION"
#set -x






V() {

if [ ! -z "$VERBOSE" ]; then
	echo "${1}" >&2
fi

}









TMPdO="/tmp/$(basename $0)"; mkdir -p $TMPdO





#NOTE SCRIPT WAS ALREADY REMOVING!!! 'info' || list
lists_dir=$(sed -rne 's#^lists_dir \S+ (\S+)#\1#p' /etc/opkg.conf /etc/opkg/*.conf 2>/dev/null | tail -n 1)
lists_dirT="${TMPdO}/$(basename $0)-feeds-lists_dir" #must have the name feeds for auto unmounter @ > subdir
#@@@needs-param
DOTMPLISTDIR=1








#oDN_DEFAULT="downloads.openwrt.org"
oDN_DEFAULT="downloads.cdn.openwrt.org"
oH_DEFAULT="http://"
oDN="${oDN:-"$oDN_DEFAULT"}"
oH="${oH:-"${oH_DEFAULT}"}"
oS="${oS:-"${oH}${oDN}"}"




V "     server: ${oS}" #echo "oH: ${oH}"
V "  lists_dir: ${lists_dir} lists_dirT: $lists_dirT" #echo "oH: ${oH}"
#exit 0









#DOCORE=1
#echo "DOCORE=1"; sleep 2; DOCORE=1 #base-files


if [ -z "$REPOSEN_OFFICIAL" ]; then #@parse -OR ""
	REPOSEN_OFFICIAL="base packages luci routing telephony freifunk" #REPOSEN_OFFICIAL="base luci routing telephony freifunk"
fi



V "repos-enabled: ${REPOSEN_OFFICIAL}"












sanitycheck() {

if mount | grep -q '/tmp/opkg-lists'; then
	SANITY="$SANITY /tmp/opkg-lists-mounted" #echo "oops-sanity: /tmp/opkg-lists is mounted"
fi
if mount | grep -q 'feeds'; then
	SANITY="$SANITY feeds-mounted" #echo "oops-sanity: /tmp/opkg-lists is mounted"


	#SANITY="$SANITY "
	mount | grep feeds | cut -d' ' -f3 | tr -s '\n' ' '
fi



if [ ! -z "$SANITY" ]; then
	echo "$SANITY"
	return 1 #@caller && ! stop
else
	return 0
fi


}



#echo "RABBIT1"; exit 0







#set -x

#./rpi4-official-opkg.sh info dnsmasq-full -v -RO "luci" returns-results@/tmp/opkg-lists













#if ! grep -q SNAPSHOT /etc/os-release; then echo "$0 snapshot-only" && exit 0; fi

#MODELf=$(cat /tmp/sysinfo/board_name)
#case "$MODELf" in
#	*"4-model-b"*|*"rpi4"*) :; ;;
#	*) echo "model-unsupported: $MODELf"; exit 0; ;;
#esac









#set -x



##########################################BRANDNEWTESTINGwasELIFafterSTARTinALLMAIN_returnsifnotneeded
if [ "$sACTION" = "stop" ]; then
	V "stop official repos"
	opkgofficial stop; exit 0
elif [ "$sACTION" = "status" ]; then
	V "########## saction-status-main"
	echo "### sanitycheck"
	sanitycheck #if grep -q 'mounted||feeds-mounted' STARTED=1

	#IFSTARTED cat /tmp/distfeeds.conf



	#ls /var/opkg-lists/ | grep -v '\.sig' | grep git #||notupdated

	exit 0
fi













################################## note: returns-if-mounted&'stop' MOVETOFUNC@reallyrun V "enable+update official repos"
#echo "dbgstartallcalls-pre"; mount | grep feeds; sleep 2
opkgofficial start
#echo "dbgstartallcalls-post"; mount | grep feeds; sleep 2


if [ ! -z "$OPKGUPDfail" ]; then
	echo "opkg-update-failed" #@/tmp
	opkgofficial stop
	exit 0
fi












if [ "$sACTION" = "start" ]; then
	exit 0


######################################### bad-logix@STATUS+++startsinmain
#elif [ "$sACTION" = "stop" ]; then
#	V "stop official repos"
#	opkgofficial stop; exit 0



else

	#@FN now local DEBUG cat /tmp/distfeeds.conf | cut -d' ' -f2; sleep 2


	if [ ! -z "$MITIGATE" ]; then


		for pOPT in $OPKGOPTS; do

			#@@@best@mitigate
			#grep -q "$pOPT" /root/$(basename $0).mitigated && echo "already-done?: ${pOPT}"		
			#@@@
			#/bin/opkg upgrade "${pOPT}" && echo "$pOPT" >> /root/$(basename $0).mitigated #???


			pOPTstr=

			V "opkgcmd: /bin/opkg list-upgradable | grep -q ${pOPT}"
			if /bin/opkg list-upgradable | grep -q "^${pOPT} "; then
				pOPTstr=$(/bin/opkg list-upgradable | grep "^${pOPT}")
				echo "$pOPT has-fixes: $(/bin/opkg list-upgradable | grep "^${pOPT}")"

				#/bin/opkg upgrade "${pOPT}" && touch /tmp/.mitigated #1> 2> + reboot
				#/bin/opkg upgrade "${pOPT}" && echo "$pOPTstr >> /tmp/.mitigated
				

				if /bin/opkg upgrade "${pOPT}"; then #>
					echo "$pOPT upgrade [ok] restartservice-or-reboot-if-needed"
				else
					echo "$pOPT upgrade [issues?]"
					RETVAL=3
				fi


			else
				echo "$pOPT no-fixes"
			fi
		

		done

	else
		V "opkgcmd: /bin/opkg ${OPKGOPTS}"
		/bin/opkg ${OPKGOPTS}
	fi


fi








if [ ! -z "$NOSTOP" ]; then
	V "nostop"
	#@@@start||ticklebackgroundtimer_andatstart->sleep 300 && opkgofficial stop #-S
else
	V "stop official repos"
	opkgofficial stop
fi












V "DBG-ENDRET: ${RETVAL:-0}"
exit ${RETVAL:-0}



#@@@ stick guts in while -z RETVAL?

#BUG
######[root@dca632 /usbstick 48°]# ./rpi4-official-opkg.sh STATUS
### sanitycheck
########[root@dca632 /usbstick 48°]# ./run-mitigate.sh demo
#run-mitigate.sh> dnsmasq [skip-newrom]
#run-mitigate.sh> demo-fake-netifd: 2020-01-12
#run-mitigate.sh> netifd and odhcp6c are known ppp/p-t-p routing loop bug
#run-mitigate.sh> /bin/rpi4-official-opkg.sh mitigate netifd odhcp6c; reboot
#run-mitigate.sh> demo-fake-libwolfssl24: 4.5.9
#run-mitigate.sh> init> mitigating for version: 2.7.33-2 [check]  libwolfssl24
#/bin/rpi4-official-opkg.sh mitigate  libwolfssl24
#libwolfssl24 no-fixes
##########[root@dca632 /usbstick 49°]# cat /tmp/DIST
#src/gz openwrt_base http://downloads.cdn.openwrt.org/snapshots/packages/aarch64_cortex-a72/base























#src/gz git_updates https://github.com/wulfy23/rpi4-opkg/raw/master/r15673-abe348168b/updates







################################################################################
#echo "opkg ${*}"; echo "opkg ${*}"; echo "opkg ${*}" #opkg "${*}"
################################################################################
#if [ ! -z "$MASQUPDATED" ]; then
#	logger -t vulfix "dnsmasq patched: $MASQvariant $MASQmsg"
#	if [ ! -z "$MASQRUNNING" ]; then
#		[ -n "$MASQDEBUG" ] && echo "/etc/init.d/dnsmasq restart"
#		/etc/init.d/dnsmasq stop 1>/dev/null 2>/dev/null
#		sleep 3
#		/etc/init.d/dnsmasq start 1>/dev/null 2>/dev/null
#	fi
#	return 0
#fi
#logger -t vulfix "dnsmasq patch failed: $MASQvariant $MASQmsg"
#return 1

#cat <<'LLL' > /tmp/distfeeds.conf
#src/gz openwrt_base https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base
#LLL




















#MASQDEBUG=1



MASQver=$(opkg list-installed | grep dnsmasq | cut -d' ' -f3)
MASQvariant=$(opkg list-installed | sed -n '/dnsmasq/ s/\([a-z]*\) - .*/\1/p')

onsysVERSION=$(cat /etc/custom/buildinfo.txt | grep '^localversion' | cut -d'=' -f2 | sed 's/"//g' | sed "s/'//g")



#if [ ! -f /root/.dnsmasq.patched ]; then



if [ -z "$MASQver" ] || [ -z "$MASQvariant" ]; then #DBG MASQvariant=
	logger -t vulfix "masq update due to known vulnerabilities: $MASQvariant $MASQver [not-installed]"
else

case "$onsysVERSION" in #"2.3"*|"2.5"*)
	"2.5"*) touch /root/.dnsmasq.patched; ;; #next build should not have issue
	"2.3"*)

		case "$MASQver" in #"2.82"*) : ;; #"2.83"*) : ;;
			"2.82"*)

			rm /root/.dnsmasq.patched 2>/dev/null
			if [ ! -f /root/.dnsmasq.patched ]; then
				updatednsmasq
			fi
			;;
			"2.83"*)
				logger -t vulfix "masq version is ok: $MASQvariant $MASQmsg"
				touch /root/.dnsmasq.patched
			;;
			esac
		;;

	*)
		logger -t vulfix "your build is ancient update due to known vulnerabilities: $MASQvariant $MASQmsg"
	;;
esac



fi #end -z ver or variant



#fi #end ! -f patched












































##curl -sSL https://raw.githubusercontent.com/wulfy23/rpi4/master/utilities/dnsmasqfix.sh > /tmp/dnsmasqfix.sh; chmod +x /tmp/dnsmasqfix.sh; /tmp/dnsmasqfix.sh







#!/bin/sh




updatednsmasq() {


cat <<'LLL' > /tmp/distfeeds.conf
src/gz openwrt_base https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base
LLL
cat <<'LLL' > /tmp/customfeeds.conf
#
LLL

mount -o bind /tmp/distfeeds.conf /etc/opkg/distfeeds.conf
mount -o bind /tmp/customfeeds.conf /etc/opkg/customfeeds.conf



#MASQDEBUG=1
#MASQvariant=

if [ -n "$MASQDEBUG" ] && [ -z "$MASQvariant" ]; then
	MASQmsg="$MASQmsg dnsmasq is not installed"
	NOVARIANT=1
elif [ -n "$MASQDEBUG" ]; then
	#echo "Checking for newer version for $MASQvariant $MASQver $onsysVERSION"
	LOGMSG "Checking for newer version for $MASQvariant $MASQver $onsysVERSION"
fi



#if [ -z "$MASQvariant" ]; then MASQmsg="$MASQmsg dnsmasq is not installed"


if [ -n "$MASQDEBUG" ]; then #if [ -n "$MASQDEBUG" ] && [ ! -z "$MASQvariant" ]; then
	#echo "opkg update 1>/dev/null 2>/dev/null" #opkg update
	if ! opkg update 1>/dev/null 2>/dev/null; then
		MASQmsg="$MASQmsg opkgupdatefailed"
		OPKGUPDfail=1
	fi
else #elif [ ! -z "$MASQvariant" ]; then
	if ! opkg update 1>/dev/null 2>/dev/null; then
		MASQmsg="$MASQmsg opkgupdatefailed"
		OPKGUPDfail=1
	fi
fi




if [ -z "$OPKGUPDfail" ] && [ -z "$NOVARIANT" ] && opkg list-upgradable | \
	cut -d' ' -f1 | grep -q "^$MASQvariant$"; then #@@@propervariant


	VERFOUND=$(opkg list-upgradable | grep 'dnsmasq')

	[ -n "$MASQDEBUG" ] && echo "VERFOUND: $(opkg list-upgradable | grep 'dnsmasq')"

	if [ ! -z "$(pidof dnsmasq)" ]; then MASQRUNNING=1 ; fi


	[ -n "$MASQDEBUG" ] && echo "opkg upgrade $MASQvariant"

	if [ -n "$MASQDEBUG" ]; then
		if opkg upgrade $MASQvariant; then
			MASQUPDATED=1
		else
			MASQmsg="${MASQmsg} opkgupgradecmdfailed"
		fi
	else
		if opkg upgrade $MASQvariant 1>/dev/null 2>/dev/null; then
			MASQUPDATED=1
		else
			MASQmsg="${MASQmsg} opkgupgradecmdfailed"
		fi
	fi


else
	[ -n "$MASQDEBUG" ] && opkg list-upgradable
	MASQmsg="${MASQmsg} no-update-${MASQvariant}-${MASQver}"
fi


while [ ! -z "$(mount | grep feeds | cut -d' ' -f3)" ]; do
	umount $(mount | grep feeds | cut -d' ' -f3 | head -n1) 1>/dev/null 2>/dev/null
done; rm /tmp/distfeeds.conf 2>/dev/null; rm /tmp/customfeeds.conf 2>/dev/null



if [ ! -z "$MASQUPDATED" ]; then
	#logger -t vulfix "dnsmasq patched: $MASQvariant $MASQmsg"
	LOGMSG "dnsmasq patched: $MASQvariant $MASQmsg $VERFOUND"
	if [ ! -z "$MASQRUNNING" ]; then
		#[ -n "$MASQDEBUG" ] && echo "/etc/init.d/dnsmasq restart"
		LOGMSG "dnsmasq restart"
		/etc/init.d/dnsmasq stop 1>/dev/null 2>/dev/null
		sleep 3
		/etc/init.d/dnsmasq start 1>/dev/null 2>/dev/null
	fi
	return 0
fi


#logger -t vulfix "dnsmasq patch failed: $MASQvariant $MASQmsg"
LOGMSG "dnsmasq patch failed: $MASQvariant $MASQmsg"
return 1

}





#MASQDEBUG=1

LOGMSG() {
	logger -t vulfix "${1}"
	echo "${1}"
}
















MASQver=$(opkg list-installed | grep dnsmasq | cut -d' ' -f3)
MASQvariant=$(opkg list-installed | sed -n '/dnsmasq/ s/\([a-z]*\) - .*/\1/p')

onsysVERSION=$(cat /etc/custom/buildinfo.txt | grep '^localversion' | cut -d'=' -f2 | sed 's/"//g' | sed "s/'//g")













#meh... bump to 2.5 will do it
############################# set all 2.3 on then turn recent off for now
#case "$onesysVERSION" in
#    *"2.3."*)
#        NEEDSUPDATE=1
#    ;;
#esac
##case "$onesysVERSION" in
##    *"2.3.9"*) #meh will match 9 - 90
##        NEEDSUPDATE=
##    ;;
##esac
###############################################################if NEEDSUPDATE tba
#rpi-4_snapshot_2.3.656-15_r15323_extra  rpi-4_snapshot_2.3.656-16_r15323_std  rpi-4_snapshot_2.3.770-13_r15549_extra



















#if [ ! -f /root/.dnsmasq.patched ]; then


if [ -z "$MASQver" ] || [ -z "$MASQvariant" ]; then #DBG MASQvariant=
	LOGMSG "masq update due to known vulnerabilities: $MASQvariant $MASQver [not-installed]"
else


case "$onsysVERSION" in #"2.3"*|"2.5"*)
	"2.5"*|"2.7"*)
		LOGMSG "new build no check needed: $MASQvariant $MASQmsg $MASQver"
        touch /root/.dnsmasq.patched
        ;; #next build should not have issue
	"2.3"*)

		case "$MASQver" in #"2.82"*) : ;; #"2.83"*) : ;;
			"2.82"*|"2.83"*) #"2.82"*)

			rm /root/.dnsmasq.patched 2>/dev/null
			if [ ! -f /root/.dnsmasq.patched ]; then
				updatednsmasq
			fi
			;;
			"2.83"*)
				#logger -t vulfix "masq version is ok: $MASQvariant $MASQmsg $MASQver"
				LOGMSG "masq version is ok: $MASQvariant $MASQmsg $MASQver"
				touch /root/.dnsmasq.patched
			;;
			esac
		;;

	*)
		#logger -t vulfix "your build is ancient update due to known vulnerabilities: $MASQvariant $MASQmsg"
		LOGMSG "your build is ancient update due to known vulnerabilities: $MASQvariant $MASQmsg $MASQver"
	;;
esac




fi #end -z ver or variant



#fi #end ! -f patched







#curl -sSL https://raw.githubusercontent.com/wulfy23/rpi4/master/utilities/dnsmasqfix.sh > /tmp/dnsmasqfix.sh; chmod +x /tmp/dnsmasqfix.sh; /tmp/dnsmasqfix.sh








#!/bin/sh

cp /etc/opkg/distfeeds.conf /tmp/distfeeds.conf
echo "#" > /tmp/customfeeds.conf

sed -i 's!https!http!g' /tmp/distfeeds.conf
sed -i 's!downloads\.openwrt!downloads\.cdn\.openwrt!g' /tmp/distfeeds.conf


cp /usbstick/distfeeds.conf_cdnallon_http /tmp/distfeeds.conf
#cp /usbstick/distfeeds.conf_cdnallon_https /tmp/distfeeds.conf





mount -o bind /tmp/distfeeds.conf /etc/opkg/distfeeds.conf
mount -o bind /tmp/customfeeds.conf /etc/opkg/customfeeds.conf


echo "############# run1 cdn cache fill"
time opkg update

echo "############# run2 cdn cache direct"
time opkg update



#opkg list-upgradable



while [ ! -z "$(mount | grep feeds | cut -d' ' -f3)" ]; do
	umount $(mount | grep feeds | cut -d' ' -f3 | head -n1) 1>/dev/null 2>/dev/null
done; #rm /tmp/distfeeds.conf 2>/dev/null rm /tmp/customfeeds.conf 2>/dev/null














opkgofficial20210205() {



#oDN="downloads.openwrt.org"
#oH="http://"
#oS="${oH}${oDN}"


#@@@SNAPSHOT only check


	case "$1" in
	start)

	if mount | grep -q '/etc/opkg/distfeeds.conf' && mount | grep -q '/etc/opkg/customfeeds.conf'; then return 0; fi
#src/gz openwrt_core https://downloads.openwrt.org/snapshots/targets/bcm27xx/bcm2711/packages
#cat <<'LLL' > /tmp/distfeeds.conf
cat <<LLL > /tmp/distfeeds.conf
src/gz openwrt_base ${oS}/snapshots/packages/aarch64_cortex-a72/base
src/gz openwrt_freifunk ${oS}/snapshots/packages/aarch64_cortex-a72/freifunk
src/gz openwrt_luci ${oS}/snapshots/packages/aarch64_cortex-a72/luci
src/gz openwrt_packages ${oS}/snapshots/packages/aarch64_cortex-a72/packages
src/gz openwrt_routing ${oS}/snapshots/packages/aarch64_cortex-a72/routing
src/gz openwrt_telephony ${oS}/snapshots/packages/aarch64_cortex-a72/telephony
LLL
################################################################ Enable kmods repository kmods-show-with-this-off@core->yes
. /etc/openwrt_release
KERNEL="$(opkg list-installed kernel)"
cat << EOF >> /tmp/distfeeds.conf
src/gz openwrt_kmods http://downloads.openwrt.org/\
snapshots/targets/${DISTRIB_TARGET}/kmods/${KERNEL##* }
EOF
########################################################################################





#echo "########## DEBUG /tmp/distfeeds.conf"; cat /tmp/distfeeds.conf; exit 0



if [ ! -z "$DOCORE" ]; then
	echo "src/gz openwrt_core ${oS}/snapshots/targets/bcm27xx/bcm2711/packages" >> /tmp/distfeeds.conf
fi

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
	fi

	;;
	stop)
		while [ ! -z "$(mount | grep feeds | cut -d' ' -f3)" ]; do
			umount $(mount | grep feeds | cut -d' ' -f3 | head -n1) 1>/dev/null 2>/dev/null
		done; rm /tmp/distfeeds.conf 2>/dev/null; rm /tmp/customfeeds.conf 2>/dev/null
	;;
	esac

}









##############oDN="downloads.openwrt.org" #oDN="downloads.cdn.openwrt.org"
#oDN="downloads.cdn.openwrt.org"
#oH="http://"
#LATER oS="${oH}${oDN}"





##############################################Ok
#oDN="${oDN:-"downloads.openwrt.org"}"
#oH="${oH:-"http://"}"
#oS="${oS:-"${oH}${oDN}"}"
################################################3
###TOP oDN_DEFAULT="downloads.openwrt.org"
###TOP oH_DEFAULT="http://"
oDN="${oDN:-"$oDN_DEFAULT"}"
oH="${oH:-"${oH_DEFAULT}"}"
oS="${oS:-"${oH}${oDN}"}"



#src/gz openwrt_base https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base




#exit 0
#####src/gz openwrt_core https://downloads.openwrt.org/snapshots/targets/bcm27xx/bcm2711/packages
####src/gz openwrt_base https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base
#src/gz openwrt_kmods https://downloads.openwrt.org/snapshots/targets/bcm27xx/bcm2711/kmods/5.4.94-1-d38e2aaa338add4a409aced8a9c159b0
#src/gz openwrt_freifunk https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/freifunk
####src/gz openwrt_luci https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/luci
#src/gz openwrt_packages https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/packages
#src/gz openwrt_routing https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/routing
#src/gz openwrt_telephony https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/telephony







rm /tmp/$(basename $0).opkgurls2 2>/dev/null
cat /etc/opkg/distfeeds.conf | cut -d' ' -f3 | cut -d'/' -f4- > /tmp/$(basename $0).opkgurls1
cat /tmp/$(basename $0).opkgurls1 | while read DODO; do
	dirname $DODO >> /tmp/$(basename $0).opkgurls2
done
cat /tmp/$(basename $0).opkgurls2 | sort | uniq




#echo "cat $repoFs 2>/dev/null | grep core | cut -d' ' -f3"
#cat $repoFs 2>/dev/null | grep core | cut -d' ' -f3
#####
#echo "cat /etc/opkg/distfeeds.conf | grep openwrt_core | cut -d' ' -f3 | cut -d'/' -f4-"
#cat /etc/opkg/distfeeds.conf | grep openwrt_core | cut -d' ' -f3 | cut -d'/' -f4-
#####
#cat $repoFs 2>/dev/null | grep core | cut -d' ' -f3 | cut -d'/' -f4-



#set -x


#getopkgurlpath official core
#getopkgurlpath custom core





