#!/bin/sh



TMPd="/tmp"


WGET="wget --no-parent -q -nd -l1 -nv --show-progress "
WGETs="wget --no-parent -q -nd -l1 -nv "
Gbase="https://raw.github.com/wulfy23/rpi4/master/utilities"




#works in mitigate.sh but not here
SN=$(basename $0)
#SI=$(basename $0)






fails() {
    echo "$1" && exit 1
}





V() {
	if [ ! -z "$VERBOSE" ] || [ ! -z "$DEBUG" ]; then #if [ ! -z "$VERBOSE" ]; then
		if [ ! -z "$ISSCRIPT" ]; then
			logger $(basename $0) "${*}"
		else

			echo "$(basename $0)> ${*}" >&2
		fi

		if [ -z "$QUICK" ]; then sleep 1; fi
	fi
}



O() {
	if [ ! -z "$ISSCRIPT" ]; then
		logger $(basename $0) "O> ${*}"
	else
		echo "$(basename $0)> ${*}" #echo "$SN> ${*}"
		echo "$(basename $0)-O-$Dy> ${*}" > /dev/console
	fi
	#if [ -z "$QUICK" ]; then sleep 1; fi
}





D() { #avoidusingthis@v||!-zDEBUG
	if [ ! -z "$DEBUG" ]; then
		if [ ! -z "$ISSCRIPT" ]; then
			logger $(basename $0) "D: ${*}"
		else
			echo "$(basename $0) -D: ${*}" #>&2
		fi
		if [ ! -z "$QUICK" ]; then sleep 1; fi
	fi
}















handleallparams() { #local FN="handleallparams"; #echo "$FN> 1 $1"; echo "$FN> 2 $2"; echo "$FN> all $@"; sleep 3

	set -- "${@}"
	while [ "$#" -gt 0 ]; do
		#echo "param: $1"

		case "$1" in
		--help|-h|help) #--help|-h|help)
			usage && exit
		;;
		-f|force)
			FORCE=1
			#cmdParam="$cmdParam $1" #wrappednotneededasbelow
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
		-S)
			ISSCRIPT=1
			cmdParam="$cmdParam $1"
		;;
		-N)
			NOACTION=1
			cmdParam="$cmdParam $1"
		;;
		demo)
			DEMO=1
			#cmdParam="$cmdParam $1"
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
		-v			verbose
		-Q			quick


		-N			noaction



		-S ISSCRIPT -> logger (same as cron)

		cron



		-f			force (skip rerun pacer) +?
		demo			fakeoldstuff


VVV

}













#set -x


ALLPARAMS="${*}" #ALTERNATE-ASSIGN-PROPERPARAMS@PROBABLE dump all to file and use 'stats' post dump
handleallparams ${*}
#echo "      allparams: $ALLPARAMS"; echo "    customParam: $customParam"; echo "       cmdParam: $cmdParam"








Dy=$(date +%Y%m%d-%H%M)
OUTFILE="/tmp/$(basename $0)-result-$Dy"


#Bname="mitigate.sh"
#BFULL="${TMPd}/${Bname}" #||BFULL



D "### proc ppid cmdline $(cat /proc/$PPID/cmdline)"
D "### proc \$\$ cmdline $(cat /proc/$$/cmdline)"




if [ ! -z "$ISSCRIPT" ]; then
	QUICK=1
fi








if [ -f /root/wrt.ini ] && ! grep -q "UPDATECHECK_MITIGATE" /root/wrt.ini 2>/dev/null; then
	echo "UPDATECHECK_MITIGATE=\"norun\"" >> /root/wrt.ini
fi




eval $(grep '^UPDATECHECK_MITIGATE' /root/wrt.ini 2>/dev/null)

#noinline!ALL||
eval $(grep '^SCRIPT_OPTS' /root/wrt.ini 2>/dev/null)





#@@@>D
V "UPDATECHECK_MITIGATE: ${UPDATECHECK_MITIGATE-noentry}"
V "SCRIPT_OPTS: ${SCRIPT_OPTS-noentry}"







#@@@move to funcs@noonline
if [ ! -z "$SCRIPT_OPTS" ]; then
	case "$SCRIPT_OPTS" in
		noonline)
			V "noline $0 disabled"
			echo "$(basename $0) noline $0 disabled" > /dev/console
		;;
		warnonly)
			V "warnonly detected"
			echo "$(basename $0) warnonly detected" > /dev/console
		;;
	esac
fi














############################### OFF<wrecksnewfixneeded>timebased : #perfixorother@tbavuln||&&+date etc
#if [ ! -z "$DEMO" ]; then
#	O "rom-is-new->DEMO: repeatcheckFORCEON: $onsysVERSION"
#else
	#if [ -f /tmp/$(basename $0).newrom ]; then
	#	O "rom-is-new: repeatchecksuneeded: $onsysVERSION" && exit 0
	#fi
#fi








if [ ! -f /tmp/$(basename $0).$(date +%Y%m%d) ]; then
	touch /tmp/$(basename $0).$(date +%Y%m%d)
else
	NORUN="${NORUN} ffile:/tmp/$(basename $0).$(date +%Y%m%d)"
fi





#@@@probably ignore on 'nonluci'||-S

#if [ ! -z "$NORUN" ] && [ -z "$DEMO" ]; then
if [ ! -z "$NORUN" ] && [ ! -z "$FORCE" ]; then
	O "norun: $NORUN [force]"
elif [ ! -z "$NORUN" ] && [ -z "$DEMO" ]; then
	O "norun: $NORUN"
	exit 0
fi


#if [ ! -f /tmp/$(basename $BFULL)-$(date +%Y%m%d%H) ]; then
#else
#	D "using cached $(basename $BFULL) $(date +%Y%m%d%H)"
#fi










####################################### noupdatesonthis
Bname="rpi4-official-opkg.sh"
BFULL="/bin/rpi4-official-opkg.sh"
if [ ! -f "$BFULL" ]; then
	echo "$(basename $) Download: $Bname"; #sleep 1

    $WGETs -O $BFULL "${Gbase}/$Bname" || OOPSIE=1
    if [ ! -z "$OOPSIE" ]; then
	    	rm $BFULL 2>/dev/null
		fails "dlprob"
    fi
    chmod +x $BFULL
#else
#    echo "$BFULL [present]"
fi
















if echo $sACTION | grep -q cron; then
	ISCRON=1
fi





################################################ OLDPARSE@IMPORTSAMPLES
#if [ -z "$1" ]; then sACTION="simple"; fi
#if [ "$sACTION" != "simple" ]; then
#	while [ "$#" -gt 0 ]; do sACTION="$sACTION $1"; shift; done
#fi
################################################ OLDPARSE@IMPORTSAMPLES
#DEBUG=1
#if [ -n "$DEBUG" ]; then
#	echo "             fullcmd: $BFULL"
#	echo "        OUTFILE(pfx): $OUTFILE"
#	echo "  sACTION(allparams): $sACTION"
#fi
#exit 0

#set -x


D "outfile: $OUTFILE"











#RUMRUM

MODELf=$(cat /tmp/sysinfo/board_name)

case "$MODELf" in
	*"4-model-b"*|*"rpi4"*)
		:
	;;
	*)
		O "model-unsupported: $MODELf"
	;;
esac
#case "$(cat /tmp/sysinfo/board_name)" in '4-model-b') #echo "MODELf: $MODELf"









onsysVERSION=$(cat /etc/custom/buildinfo.txt | grep '^localversion' | cut -d'=' -f2 | sed 's/"//g' | sed "s/'//g")







MASQver=$(opkg list-installed | grep dnsmasq | cut -d' ' -f3)
MASQvariant=$(opkg list-installed | sed -n '/dnsmasq/ s/\([a-z]*\) - .*/\1/p')

#MASQnewIPK="dnsmasq_2.82-10_aarch64_cortex-a72.ipk"
#MASQnewipkURL="https://downloads.openwrt.org/snapshots/packages/aarch64_cortex-a72/base/$MASQnewIPK"
##############base/dnsmasq_2.82-10_aarch64_cortex-a72.ipk #/usr/sbin/dnsmasq




#echo "localversion: $onsysVERSION"
#if [ ! -f /root/.dnsmasq.patched ]; then





case "$onsysVERSION" in #"2.3"*|"2.5"*)
	"2.5"*|"2.7"*) #logger -t vulfix "newbuild-no-check-needed: $MASQvariant $MASQmsg"; touch /root/.dnsmasq.patched
		#O "up-to-datish: $onsysVERSION"
		onsysVERSIONi="uptodate"
	;;
	"2.3"*) #echo "/bin/rpi4-official-opkg.sh mitigate dnsmasq-full netifd odhcp6c"
		O "update-soon: $onsysVERSION"
		onsysVERSIONi="update-soon"
	;;
	"1"*) #echo "/bin/rpi4-official-opkg.sh mitigate dnsmasq-full netifd odhcp6c"
		O "reallyold: $onsysVERSION"
		onsysVERSIONi="old"
		exit 1
	;;

	*) #logger -t vulfix "your build is ancient update due to known vulnerabilities: $MASQvariant $MASQmsg"
		#O "reallynew: $onsysVERSION"
		onsysVERSIONi="brandnew"
	;;
esac




#@@@+VERSION?



#if [ ! -z "$DEMO" ]; then
#	O "rom-is-new->DEMO: repeatcheckFORCEON: $onsysVERSION"
#else
	#: #perfixorother@tbavuln||&&+date etc
	##if [ -f /tmp/$(basename $0).newrom ]; then
	##	O "rom-is-new: repeatchecksuneeded: $onsysVERSION" && exit 0
	##fi
#fi


if [ ! -z "$onsysVERSIONi" ] && [ "$onsysVERSIONi" = "uptodate" ]; then
	touch /tmp/$(basename $0).newrom
fi















SKUPTHEETWO() {




if [ -z "$MASQver" ] || [ -z "$MASQvariant" ]; then #DBG MASQvariant=
	logger -t run-mitigate.sh "masq update due to known vulnerabilities: $MASQvariant $MASQver [not-installed]"
else


	if [ ! -z "$onsysVERSIONi" ] && [ "$onsysVERSIONi" = "uptodate" ]; then
		O "dnsmasq [skip-newrom]"
	else

	case "$MASQver" in
	#"2.82"*|"2.83"*|"2.84~"*)
	"2.82"*|"2.83"*)
		V "dnsmasq-full [mitigate:$MASQver]"
		MITPKG="${MITPKG} dnsmasq-full"
	;;
	"2.84"*)
		O "dnsmasq-full [ok:$MASQver]"
	#logger -t vulfix "masq version is ok: $MASQvariant $MASQmsg"
		#touch /root/.dnsmasq.patched
	;;
	*)
		echo "dnsmasq-full [nocase:$MASQver]"
		O "dnsmasq-full [nocase:$MASQver]"
	;;
	esac

	fi #enduptodatebypass


fi #ENDmasqvernotz




















LIBWOLFSSL24ver=$(opkg list-installed | grep "^libwolfssl24 " | cut -d' ' -f3)

if [ ! -z "$DEMO" ]; then ########################### debugfixups
	onsysVERSIONi="check" #fixatmainset
	LIBWOLFSSL24ver="4.5.9"
	O "demo-fake-libwolfssl24: $LIBWOLFSSL24ver" #!@-S echo "demo fake libssl"
fi





if [ ! -z "$LIBWOLFSSL24ver" ]; then #DBG MASQvariant=

	if [ ! -z "$onsysVERSIONi" ] && [ "$onsysVERSIONi" = "uptodate" ]; then
		: #echo "skiplibwolfssl24check-uptodate"
		#O "skiplibwolfssl24check-uptodate"
		O "libwolfssl24 [skip-newrom]" #V
	else




	#FAKE

	case "$LIBWOLFSSL24ver" in
	"4.6.0"*) #REAL
		O "libwolfssl24 [ok:$LIBWOLFSSL24ver]" #V
	;;
	*)
		V "libwolfssl24 [mitigate:$LIBWOLFSSL24ver]"
		MITPKG="${MITPKG} libwolfssl24"
	;;
	#;;
	#*)
	#	echo "libwolfssl24 [nocase:$LIBWOLFSSL24ver]"
	#;;
	esac



	fi


fi #libwolfssl24 version 4.6.0



}

































#/bin/rpi4-official-opkg.sh mitigate wpad-openssl hostapd-common hostapd-utils wpa-cli
#/bin/rpi4-official-opkg.sh mitigate wget-ssl






WARNPKG="libwolfssl24 dnsmasq-full wpad-openssl hostapd-common hostapd-utils wpa-cli"
for dDAH in $WARNPKG; do
    echo -n "rpi4-official-opkg.sh list-upgradable | grep \"$dDAH\""
    if rpi4-official-opkg.sh list-upgradable | grep -q "^$dDAH$"; then
        echo " > MITIGATEMANUALLY: rpi4-official-opkg.sh upgrade \"$dDAH\""
    else
        echo " > $dDAH no-fixes"
    fi
done








#WARNPKG="openvpn-openssl netifd odhcp6c"
WARNPKG="netifd odhcp6c"
for dDAH in $WARNPKG; do
    echo -n "rpi4-official-opkg.sh list-upgradable | grep \"$dDAH\""
    if rpi4-official-opkg.sh list-upgradable | grep -q "^$dDAH$"; then
        #echo " > MITIGATEMANUALLY: rpi4-official-opkg.sh upgrade \"$dDAH\""
        UPDATEnetifd=1
    #else
    #    echo " > $dDAH no-fixes"
    fi
done



if [ ! -z "$UPDATEnetifd" ]; then

        echo "rpi4-official-opkg.sh upgrade \"netifd\"; sleep 5"
        rpi4-official-opkg.sh upgrade netifd
        sleep 5
        echo "rpi4-official-opkg.sh upgrade \"odhcp6c\""
        rpi4-official-opkg.sh upgrade odhcp6c

else
        echo " > netifd no-fixes"
fi #opkg upgrade netifd; sleep 5; opkg upgrade odhcp6c





















#echo "mitigating for version: $onsysVERSION [$onsysVERSIONi]"




#@@@cache@rerunintmp?||resultlinelower
O "init> mitigating for version: $onsysVERSION [$onsysVERSIONi] ${MITPKG:-no-packages-needed-or-aslisted-above}"








if [ ! -z "$onsysVERSIONi" ] && [ "$onsysVERSIONi" = "old" ]; then
	O "too-old to mitigate" && exit 1
fi








if [ ! -z "$MITPKG" ]; then
	#echo "mitigate packages: $MITPKG"


	if [ ! -z "$NOACTION" ]; then
		#L()? #logger mitigate "NOACTION: /bin/rpi4-official-opkg.sh mitigate $MITPKG"
		O "NOACTION: /bin/rpi4-official-opkg.sh mitigate $MITPKG"
	else
		echo "/bin/rpi4-official-opkg.sh mitigate $MITPKG" #V
		/bin/rpi4-official-opkg.sh mitigate $MITPKG
		#echo $?
		#@@@retval or inscript echo "may need service restart or reboot"
	fi




	#rpi4-official-opkg.sh -RO base list-upgradable nostop #stop|start @ repochange TODo
	#rpi4-official-opkg.sh stop




	#echo "/bin/rpi4-official-opkg.sh start"; /bin/rpi4-official-opkg.sh start
	#for mPKG in $MITPKG; do
	#	echo "/bin/rpi4-official-opkg.sh mitigate $mPKG"
	#	/bin/rpi4-official-opkg.sh mitigate $mPKG
	#done
	#echo "/bin/rpi4-official-opkg.sh stop"; /bin/rpi4-official-opkg.sh stop


fi #PRINTED@init else O "mitigate packages [none-needed]" #@V













exit 0










###if rpi4-official-opkg.sh list-upgradable | grep -q wpad-openssl; then ./rpi4-official-opkg.sh upgrade wpad-openssl; fi
###if rpi4-official-opkg.sh list-upgradable | grep -q hostapd-common; then ./rpi4-official-opkg.sh upgrade hostapd-common; fi
###if rpi4-official-opkg.sh list-upgradable | grep -q hostapd-utils; then ./rpi4-official-opkg.sh upgrade hostapd-utils; fi

####if rpi4-official-opkg.sh list-upgradable | grep -q wpa-cli; then ./rpi4-official-opkg.sh upgrade wpa-cli; fi
####if rpi4-official-opkg.sh list-upgradable | grep -q wget-ssl; then ./rpi4-official-opkg.sh upgrade wget-ssl; fi

#/bin/rpi4-official-opkg.sh mitigate wpad-openssl hostapd-common hostapd-utils wpa-cli
#/bin/rpi4-official-opkg.sh mitigate wget-ssl












SKIPTHIS() {

#NETIFDmatch= #"2020"*|2021 #netifd - 2021-01-09-c00c8335-1




NETIFDver=$(opkg list-installed | grep "^netifd " | cut -d' ' -f3)
if [ ! -z "$DEMO" ]; then
	#NETIFDver="1996-01-12"
	NETIFDver="2020-01-12"
	O "demo-fake-netifd: $NETIFDver"
fi
if [ ! -z "$NETIFDver" ]; then


	if [ ! -z "$onsysVERSIONi" ] && [ "$onsysVERSIONi" = "uptodate" ] && [ -z "$DEMO" ]; then
		O "netifd/odhcp6c [skip-newrom]"
	else




	case "$NETIFDver" in
	"2020"*) #FAKEOLD
		V "netifd [mitigate:$NETIFDver]"
		#logger run-mitigate.sh "netifd and odhcp6c are known ppp/p-t-p routing loop bug"
		#logger run-mitigate.sh "/bin/rpi4-official-opkg.sh mitigate netifd odhcp6c; reboot"
		O "netifd and odhcp6c are known ppp/p-t-p routing loop bug"
		O "/bin/rpi4-official-opkg.sh mitigate netifd odhcp6c; reboot"
		#MITPKG="${MITPKG} netifd odhcp6c"
		#opkg update; opkg upgrade netifd; sleep 5; opkg upgrade odhcp6c
	;;
	"2021-01-09"*)
		#V "netifd [ok:$NETIFDver]"
		O "netifd [ok:$NETIFDver]"
	;;
	#;;
	*)
		echo "netifd [nocase:$NETIFDver]"
		O "netifd [nocase:$NETIFDver]"
	;;
	esac


	fi



fi
#logger -t vulfix "masq version is ok: $MASQvariant $MASQmsg" #touch /root/.dnsmasq.patched


}




















case "$onsysVERSION" in #"2.3"*|"2.5"*)
	"2.5"*|"2.7"*)
		logger -t vulfix "newbuild-no-check-needed: $MASQvariant $MASQmsg"
        	touch /root/.dnsmasq.patched
        ;;
	"2.3"*)

		echo "/bin/rpi4-official-opkg.sh mitigate dnsmasq-full netifd odhcp6c"
		#/bin/rpi4-official-opkg.sh mitigate dnsmasq-full netifd odhcp6c

	;;

	*)
		logger -t vulfix "your build is ancient update due to known vulnerabilities: $MASQvariant $MASQmsg"

	;;
esac

















		case "$MASQver" in #"2.82"*) : ;; #"2.83"*) : ;;
			"2.82"*|"2.83"*) #"2.82"*)

			rm /root/.dnsmasq.patched 2>/dev/null
			if [ ! -f /root/.dnsmasq.patched ]; then
				updatednsmasq
				#updatednsmasq 2>/dev/null 1>/dev/null #ONNEXTRUN@newver && touch /root/.dnsmasq.patched
			fi
			;;
			"2.83"*)
				logger -t vulfix "masq version is ok: $MASQvariant $MASQmsg"
				touch /root/.dnsmasq.patched
			;;
		esac
























echo "/bin/rpi4-official-opkg.sh mitigate dnsmasq-full netifd odhcp6c"
/bin/rpi4-official-opkg.sh mitigate dnsmasq-full netifd odhcp6c




exit 0






#	echo "             fullcmd: $BFULL"
#	echo "        OUTFILE(pfx): $OUTFILE"
#	echo "  sACTION(allparams): $sACTION"





#rpi-4//snapshot/repogen/r15554-1bd005ea53/base/netifd_2021-01-09-c00c8335-1_aarch64_cortex-a72.ipk
#rpi-4//snapshot/repogen/r15169-36e0268aa6/base/netifd_2020-11-30-42c48866-1_aarch64_cortex-a72.ipk
#rpi-4//snapshot/repogen/r15468-0f8fd1d0bf/base/netifd_2021-01-05-0c834396-1_aarch64_cortex-a72.ipk

#		case "$rootpart" in
#			PARTUUID=[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]-[a-f0-9][a-f0-9])
#				#uuid="${rootpart#PARTUUID=}"; uuid="${uuid%-[a-f0-9][a-f0-9]}"
#			;;
#			PARTUUID=????????-????-????-????-??????????02)













#curl -sSL https://raw.githubusercontent.com/wulfy23/rpi4/master/utilities/dnsmasqfix.sh > /tmp/dnsmasqfix.sh; chmod +x /tmp/dnsmasqfix.sh; /tmp/dnsmasqfix.sh





#https://openwrt.org/advisory/start










#######@@@console@cron
#run-mitigate.sh-O-20210205-0859> norun:  ffile:/tmp/run-mitigate.sh.20210205
#run-mitigate.sh warnonly detected
#run-mitigate.sh-O-20210205-0959> norun:  ffile:/tmp/run-mitigate.sh.20210205
#run-mitigate.sh warnonly detected
#run-mitigate.sh-O-20210205-1059> norun:  ffile:/tmp/run-mitigate.sh.20210205
#run-mitigate.sh warnonly detected
#run-mitigate.sh-O-20210205-1159> norun:  ffile:/tmp/run-mitigate.sh.20210205











#./rpi4-official-opkg.sh list-upgradable
#./rpi4-official-opkg.sh upgrade wpad-openssl
#./rpi4-official-opkg.sh upgrade hostapd-common hostapd-utils
#-28 > -29

#./rpi4-official-opkg.sh upgrade wpa-cli




#/bin/rpi4-official-opkg.sh upgrade --force-reinstall --force-maintainer banip luci-app-banip


#banip - 0.3.13-1 - 0.7.0-1
#luci-app-banip - git-20.110.55046-74da73b - git-21.035.54354-f89450f





#opkg update; opkg upgrade netifd; sleep 5; opkg upgrade odhcp6c

############Then verify, that you're running fixed version.
#opkg list-installed netifd
#opkg list-installed odhcp6c
################################The above command should output following:
###netifd - 2021-01-09-c00c8335-1 - for master/snapshot
###odhcp6c - 2021-01-09-53f07e90-16 - for master/snapshot
#######netifd - 2021-01-09-753c351b-1 - for stable OpenWrt 19.07 release
#######odhcp6c - 2021-01-09-64e1b4e7-16 - for stable OpenWrt 19.07 release


























