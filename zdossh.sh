#!/bin/bash




#DEBUG=1

sINI="$(basename $0).ini"; if [ ! -f "${sINI}" ]; then [ -n "$DEBUG" ] && echo "No ini:${sINI}" &&  sleep 2; else . "${sINI}"; fi
sFF="${HOME}/.$(basename $0).firstrun" #setup flagfile #MVLOWER rm /tmp/$(basename $0).issues &>/dev/null #? setupcheck?


#####################################
rUSER="root";
ROUTERIP="192.168.1.1";
ROUTERIP="10.2.3.1";


rtrCONFd="./rtrCONF"
FLASHKEEPIMG=1
BUILDSLOCALD="/fs/sdd1/openwrt/RTNGext/cache/rpi4/builds"

#####################################
dbgthresh=1                                                         #turnsoff-checking-infofile on -c dbgthresh=5
#####################################
AKEYS="/etc/dropbear/authorized_keys"                               # openssh-server-else-here
D="$(date +%Y%m%d-%H%M)"; H="${HOSTNAME}"
#####################################


#echo "TESTIP"; ROUTERIP="192.168.1.1"; echo "TESTrUSER"; rUSER="fish" #TESTINGVALUES

rm /tmp/$(basename $0).issues &>/dev/null #? setupcheck?







setupcheck() {

#1 setupflagfile@$sFF #${HOME}/.$(basename $0).firstrun" @~sINI>DEBUGreportpresent

if [ -z "$sFF" ]; then echo "sFF empty"; exit 1; fi


if [ ! -f "${sFF}" ]; then #@@@> || [ ! -f "${sINI}" ]; then #@@@||-zIPUSERetc...
cat <<EOF

Please edit this script and add your routers-ip near the top...

        or invoke with $0   <user@ip>     ...

        or create $sINI with the following variables;


        rUSER="root"
        ROUTERIP="IPADDRESS"

        BUILDSLOCALD="PATHTODIRWITHSUBDIRSCONTAININGIMAGES-FOR-EXT4-SYSUPGRADE-params-flash-latest"
        rtrCONFd="PARENTDIRECTORY-FOR-ROUTER-AUTOEXPORTorBACKUP"
        FLASHKEEPIMG=1

EOF
    sleep 5; touch "${sFF}"; exit 0
#else
fi

    [ -n "$DEBUG" ] && echo "sFF: $sFF [ok]"
    if [ ! -z "$DEBUG" ]; then
        if [ -f "${sINI}" ]; then
            iniLcnt=$(cat ${sINI} | grep -vE '(^$|^#)' | wc -l)
            iniinfo="[ok] $iniLcnt"
            echo "sINI: $sINI $iniinfo"
        else
            echo "sINI: $sINI [nope]"
        fi
    fi

}


oscheck2() { cat /proc/version | grep -q OpenWrt; if [ $? -ne 0 ]; then echo "No ip given and not wrt = default pull"; fi; }
booloscheck() { cat /proc/version | grep -q OpenWrt; if [ $? -ne 0 ]; then return 1; else return 0; fi; }
osis2() { if [ -d /etc/dropbear ]; then AKEYS="/etc/dropbear/authorized_keys"; else AKEYS="/etc/ssh/authorised_keys"; fi; }
#if which arp; then

rdobool() {
	command="$1"
	cpath="`which $command`"
	if [ -z $cpath ]; then
		echo "Notfound $command" && return 1
	else
		echo "Found $command binary at $cpath" && return 0
	fi
}
checkFILE() { if [ ! -f "${1}" ]; then echo "$2> ${1} file not found" && exit 1; fi }
checkDIR() {
if [ ! -d "${1}" ]; then echo "$2> ${1} directory not found" && exit 1; fi
}


checkupandsshport() {
ROUTERIP="${1}"
ping -c 2 -W 2 $ROUTERIP > /dev/null
if [ $? -ne 0 ]; then return 5; fi
nc -z $ROUTERIP 22
if [ $? -ne 0 ]; then return 6; fi
return 0
}


sshfsmountdual() {

#if sshfs client is on openwrt... first run with -f so can accept key
#opkg update; opkg install openssh-sftpserver

echo "                 #######################"
echo "     REMOTEUSER: $rUSER"
echo "       ROUTERIP: $ROUTERIP"
echo "      REMOTEDIR: $sshfsREM"
echo "                 #######################"
echo "       LOCALDIR: $sshfsDIR"
echo "           USER: $USER"
echo "       REMOTEIP: $REMOTEIP"
echo "                 #######################"

case "$1" in
	mount)
		if [ ! -d "$sshfsDIR" ]; then
			echo "sshfs-dirL:$sshfsDIR [create]"
			mkdir -p $sshfsDIR
		else
			echo "local sshfs-dir: $sshfsDIR [exists]"
		fi
		if mount | grep -q "$sshfsREM"; then
			echo "sshfsdir is mounted"; sleep 1; mount | grep "$sshfsREM"
		else
			sshfs -o allow_other,IdentityFile=~/.ssh/id_rsa $sshfsREM $sshfsDIR
			mount | grep fuse.sshfs
		fi
	;;
	umount)
		if mount | grep -q "$sshfsREM"; then
			fusermount -u $sshfsDIR
			mount | grep "fuse.sshfs"
		else
			echo "sshfsdir is not mounted"
		fi
		if [ -d "$sshfsDIR" ]; then
			lsnum="`ls -1 $sshfsDIR/ | wc -l`"
			if [ "$lsnum" -lt 1 ]; then
				echo "Removing sshfsdir: $sshfsDIR"; sleep 1
				rm -rf $sshfsDIR
			else
				echo "Leaving sshfsdir: $sshfsDIR [ has files:$lsnum ]"; sleep 1
			fi
		fi
	;;
esac

}


rtrsiggen() {

ROUTERMAC="`cat /proc/net/arp | grep "$ROUTERIP " | tail -n 1 | sed -r -e \"s/[\t\ ]+/ /g\" | cut -d' ' -f4 | cut -d':' -f 1,2,3,4,5,6 | sed -e s/\:/\"\"/g`"
if [ -z $ROUTERMAC ]; then
	echo " [nomac]" && return 2
elif [ "$ROUTERMAC" == "000000000000" ]; then
	echo " [mac-nan]" && return 3
else
	rtrSIG="$ROUTERMAC-$ROUTERIP" #rtrSIG="$ROUTERIP-$ROUTERMAC"
fi

}
#M=`cat /proc/net/arp | grep -E "${ROUTERIP} " | head -n 1 | sed "s/ \+/ /g" | cut -d' ' -f4 | sed "s/://g"`
#ecmd "remote@given"
#echo "remote execute: $M" #need to set M on host detect



checksshaccess() {
	ssh -o BatchMode=yes $rUSER@$ROUTERIP 'exit'
	if [ $? -eq 0 ]; then return 0; else return 1; fi
} #ssh -o PasswordAuthentication=no $rUSER@$ROUTERIP 'exit' || echo "SSHfailed"



rdopkglist() {

rtrOUTd="$rtrCONFd/$ROUTERMAC"; mkdir -p $rtrOUTd
rUSER=`echo $1 | cut -d'@' -f1`
ROUTERIP=`echo $1 | cut -d'@' -f2`

if [ -z "$PKGLIST" ]; then
    ssh $rUSER@$ROUTERIP 'opkg list-installed | cut -d" " -f1' >$rtrOUTd/packages-all.txt || echo "WHOOPS"
    cp $rtrOUTd/packages-all.txt $rtrOUTd/packages-all.txt-$(date +%Y%m%d-%H%M)
    cat $rtrOUTd/packages-all.txt
else
	echo "export to: $PKGLIST"
	ssh $rUSER@$ROUTERIP 'opkg list-installed | cut -d" " -f1' >$PKGLIST || echo "WHOOPS"
fi

}


rtrpkgrestore() {

rUSER=`echo $1 | cut -d'@' -f1`
ROUTERIP=`echo $1 | cut -d'@' -f2`
PKGLIST="${2}"

if [ -z "$PKGLIST" ]; then echo "PKGLIST: $PKGLIST no passed" && exit 1; fi
if [ ! -f "$PKGLIST" ]; then echo "PKGLIST: $PKGLIST does not exist" && exit 1; fi

if [ -f "/tmp/opkgrestore.log" ]; then rm -f /tmp/opkgrestore.log; fi
for pkg in $(cat $PKGLIST); do
	echo -n "####### $pkg"
	ssh $rUSER@$ROUTERIP 'opkg install '$pkg >/tmp/opkgrestore.log ; retcode=$?
	if [ $retcode -eq 0 ]; then
		echo " $retcode"
	else
		echo " $retcode"
	fi
done
echo "pkg add complete!"

if [ -f "/tmp/opkgrestore.log" ]; then
	echo "Errors occurred see /tmp/opkgrestore.log"
	cat /tmp/opkgrestore.log
fi
}





usage() {

cat<<EOF

    $0 [root@routerip]

			-c <command>

            flash <sysup.img.gz>                (note: rpi4 only)
            flash latest                        (note:rpi4-only< uses-topvar->BUILDSLOCALD)

            factorytodisk <factory.img> </dev/sdX>

            -opkgrestore <pkgs-file>
            -opkgdump <optional-outputtofile or stdout>


            confbackup
            confrestore BACKUP.tar.gz

            -M		(mount sshfs /)
            -UM		(unmount sshfs /)

            UNTESTED: factorytodisk <factory.tar.gz> /dev/sdX


EOF
echo ""

}
#echo " -exportservice adblock [-f|force]... tba -d outstartpath"



#@@@ set -k based on version or try second time if fails
#rtrCONFd="./rtrCONF"


sysupgradebackup() { FN="sysupgradebackup"

if [ -z "$ROUTERMAC" ]; then echo "$FN> $ROUTERMAC [z]" && exit 1; fi
if [ -z "$rtrCONFd" ]; then echo "$FN> rtrCONFd [z]" && exit 1; fi

rtrOUTd="$rtrCONFd/$ROUTERMAC";
mkdir -p $rtrOUTd #VERBOSEPRINT?

ssh $rUSER@$ROUTERIP sysupgrade -k -b /tmp/backup.tar.gz 2>/dev/null 1>/dev/null; retval="$?"
if [ $retval -ne 0 ]; then #echo "backup:$retval"; sleep 1
    echo "$FN> $rUSER@$ROUTERIP:/tmp/backup.tar.gz non-zero [create:$?]"
else
    [ -n "$DEBUG" ] && echo "$FN> $rUSER@$ROUTERIP:/tmp/backup.tar.gz [create:$?]"
fi
#echo "backup command failed"; return 1


scp $rUSER@$ROUTERIP:/tmp/backup.tar.gz $rtrOUTd/backup.tar.gz 2>/dev/null 1>/dev/null; retval="$?"
if [ $retval -ne 0 ]; then echo "$FN> scp-copy1 of $rUSER@$ROUTERIP:/tmp/backup.tar.gz $rtrOUTd/backup.tar.gz failed"; return 1; fi

#@@@ cp ^?
scp $rUSER@$ROUTERIP:/tmp/backup.tar.gz $rtrOUTd/backup-${rtrSIG}-$(date +%Y%m%d-%H%M).tar.gz 2>/dev/null 1>/dev/null; retval="$?"
if [ $retval -ne 0 ]; then echo "$FN> scpcopy2 of backup.tar.gz failed"; return 1; fi #@@@>testing secondcommand

echo "$FN> output: $rtrOUTd/backup-${rtrSIG}-$(date +%Y%m%d-%H%M).tar.gz"

}
#scp $rUSER@$ROUTERIP:/tmp/backup.tar.gz backup-${rtrSIG}-$(date +%F).tar.gz 2>/dev/null 1>/dev/null
#echo "output: $rtrOUTd/backup-${rtrSIG}-$(date +%F).tar.gz"
#backup-${HOSTNAME}-$(date +%F).tar.gz #echo "output: backup-${HOSTNAME}-$(date +%F).tar.gz"



sysupgraderestore() { #if [ "$dosysupput" == "y" ]; then sysupgraderestore "$rUSER@$ROUTERIP" "$2"; fi
FN="sysupgraderestore"

#1?
echo "restoring: ${1} < $RESTOREFILE"
if [ ! -f "$RESTOREFILE" ]; then echo "-sysupput FILE not PRESENT: $RESTOREFILE" && exit 1; fi
scp $RESTOREFILE $rUSER@$ROUTERIP:/tmp/backup.tar.gz 2>/dev/null 1>/dev/null
ssh $rUSER@$ROUTERIP sysupgrade -r /tmp/backup.tar.gz 2>/dev/null 1>/dev/null

}

#echo "scp $RESTOREFILE $rUSER@$ROUTERIP:/tmp/backup.tar.gz 2>/dev/null 1>/dev/null"
#echo "ssh $rUSER@$ROUTERIP sysupgrade -r /tmp/backup.tar.gz 2>/dev/null 1>/dev/null"
#1>/dev/null if [ $? -eq 0 ]; then ...




wifistationshow() {

echo "#######wlan0"
ssh $rUSER@$ROUTERIP iw dev wlan0 station dump | grep -oE '[[:xdigit:]]{2}(:[[:xdigit:]]{2}){5}'
echo "#######wlan1"
ssh $rUSER@$ROUTERIP iw dev wlan1 station dump | grep -oE '[[:xdigit:]]{2}(:[[:xdigit:]]{2}){5}'

}


exportservice() {

#1 service name i.e. adblock
#2 > outdirstart baseconfigRELEASE="cache/files-postinstall/$rtrRELEASEVERSION-services"
#2 > outdirstart "cache/files-postinstall"
#2 force?

rtrRELEASEVERSION=$(ssh $rUSER@$ROUTERIP "ubus call system board | jsonfilter -e '@[\"release\"][\"version\"]'")
echo -n "resolve router version"; sleep 1
if [ -z "$rtrRELEASEVERSION" ]; then echo " [failed]"; return 1; fi

baseconfigRELEASE="cache/files-postinstall/$rtrRELEASEVERSION-services"

isinstalled=$(ssh $rUSER@$ROUTERIP "opkg list-installed | grep '^"$1" '")

echo "#############################################################"
echo "         baseconfigRELEASE: $baseconfigRELEASE (todir)"
echo "         rtrRELEASEVERSION: $rtrRELEASEVERSION"
echo "                   service: $1 $isinstalled"

if [ -z "$isinstalled" ]; then
	echo "$1 is not installed"; sleep 2
	return 1
else
	: #echo "$1 is installed $isinstalled"; sleep 2
fi
isinstalled=
#exit 1
case "$1" in
	adblock)
		if [ -f $baseconfigRELEASE/etc/config/adblock ] && [ -z $force ]; then
			echo "config exists...: $baseconfigRELEASE/etc/config/adblock use force"; return 1
		fi
		mkdir -p $baseconfigRELEASE/etc/custom/sdata
		mkdir -p $baseconfigRELEASE/etc/config
		scp -r $rUSER@$ROUTERIP:/etc/custom/sdata/ $baseconfigRELEASE/etc/custom/sdata/
		scp -r $rUSER@$ROUTERIP:/etc/config/adblock $baseconfigRELEASE/etc/config
		return 0
	;;
	*) echo "unknown service: $1"; shift 1; ;;
esac

}



targzdo() {

TACTION="$1"; #shift
TARFILE="$2" #shift
OPTNAMEs="$3" #$@orleftparamsorwhileshiftoroptin #strings=STRING testfile=FILE

case "$1" in
    strings) #2 file #3 string #zcat $TARFILE | strings | head -n15
        zcat $TARFILE | strings | grep $3
    ;;
    testfile)
        echo "########## testfile (v1fornowjustwcprint) -> $3"
        if ! tar xf $TARFILE $3 -O 2&>- | grep -q 'Not found in archive'; then
            echo "$TARFILE > $3 [nope]" && return 1
        fi
        echo "wc-count-kernel: "
        tar xf $TARFILE $3 -O | wc -c 2> /dev/null
    ;;
    getfile) #get1(@many)
        :
    ;;
esac

}

#TARFILE="rtrCONF/dca632563177/backup.tar.gz"
#targzdo strings "$TARFILE" "loopback" #targzdo testfile "$TARFILE" "kernel"
#depth=$(awk -F/ '{print NF-1}' <<< "$file_to_extract")
#@tar zxvf mytar.tar.gz --strip-components="$depth" "$file_to_extract"
#@tar zxvf mytar.tar.gz --transform='s,.*/,,' myfolder/mysecondfolder/hello.txt
#@tar xf $TARFILE kernel -O | wc -c 2> /dev/null #@tar xf $TARFILE ^name -O | wc -c 2> /dev/null






findlatestimg() {

if [ ! -d "$BUILDSLOCALD" ]; then BUILDSLOCALD= ; fi
if [ -d "$BUILDSLOCALD" ]; then

    DIRTOSEARCH=$(ls -rt "$BUILDSLOCALD/" | grep -v 'README$' | tail -n1)
    if [ ! -d "$BUILDSLOCALD/$DIRTOSEARCH" ]; then echo "dirtosearch: $DIRTOSEARCH [notdir]" && exit 0; fi


    LATESTIMG=$(find "$BUILDSLOCALD/$DIRTOSEARCH/" -maxdepth 1 -mindepth 1 -type f | grep ext4 | grep '\-sys' | tail -n1)
    if [ ! -f "$LATESTIMG" ]; then echo "latestimg: $LATESTIMG [notfile]" && exit 0; fi

fi

}

#DBG echo "find \"$BUILDSLOCALD/$DIRTOSEARCH/\" -maxdepth 1 -mindepth 1 -type f | grep ext4 | grep '\-sys' | tail -n1"
#DBG find "$BUILDSLOCALD/$DIRTOSEARCH/" -maxdepth 1 -mindepth 1 -type f | grep ext4 | grep '\-sys'
####LATESTIMG=$(find "$BUILDSLOCALD/$DIRTOSEARCH/" | grep ext4 | grep '\-sys')
#ORG LATESTIMG=$(find "$BUILDSLOCALD/$DIRTOSEARCH/" | grep ext4 | grep sysupgrade)





#if [ "$#" -eq 0 ]; then usage && exit 1; fi
#$0 -b





pleaseConfirm() {
  ptxt=${1:-'really really sure? [y/n] : '}
  while true; do
    read -p "${ptxt}" yn
    case $yn in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo $yn' need: y or n';;
    esac
  done
} #pleaseConfirm || exit $?








if [ "$BBUG" == "y" ]; then
	if [ -z "$BBUGF" ]; then
		ecmd() { echo $1; sleep 1; }
	else
		ecmd() { echo $1 >> $BBUGF; }
	fi
else
	ecmd() { echo $1 > /dev/null; }
fi







setupcheck #sff@G sINI<DEBUG@G-reports INFORM USER ON FIRST RUN TO SET TOP VARIABLE OR CREATE ini FILE




if echo "${1}" | grep -q "@"; then ###################### LAZY PARSE cmdline passed param1 as user@ip
	#ORG rUSER=`echo $1 | cut -d'@' -f1`; ROUTERIP=`echo $1 | cut -d'@' -f2`; doREMOTE="y";
	#NOTE: TOPVAR||INI already sets these
    rUSER=${1%@*}
	ROUTERIP=${1##*@}

    ############################################################################################# DISABLINGHERE-FLAWEDLOGIC
	#doREMOTE="y" #LOOSESETTINGasPARSE/premain has to check for these too... (rUSER && ROUTERIP)
    #######################################################################################################################
    shift 1
else
    ############################################################################################# DISABLINGHERE-FLAWEDLOGIC
	: #doREMOTE="n" #NOTE: FLAWED>preparse sets sendit=y
    #######################################################################################################################
fi



####### 20200911 NOTE: doREMOTE~- > -L 'local'@~mayexist routertorouter


if [ -z "$rUSER" ]; then
    echo "rUSER not defined > root"
    #sleep 3
    rUSER="root"
fi      #202009 overridingtop... warn~>rm@202012
######################################################### 20200911 rUSERherewasforsshfsVARS>addedREMOTEIP>maycauseissues allscripttest
if [ -z "$ROUTERIP" ]; then #???>sshfs??? if [ -z "$REMOTEIP" ]; then
    echo "REMOTEIP not defined > 192.168.1.1"
    ROUTERIP="192.168.1.1"
    #sleep 3
fi      #202009 overridingtop... warn~>rm@202012






###################################################### sshfs_REMOTEDIR="/" #######realpathof #echo "`realpath $sshfsDIR`"
sshfs_LOCALDIR="${sshfs_LOCALDIR:-'./sshfs'}"
sshfsREM="${rUSER}@${ROUTERIP}:${sshfs_REMOTEDIR:-'/'}" #NOTE: sshfsREM=fullpath root@ip:/path

#####TEMPORARILY FORinFUNCTIONvarNAMECHANGE sshfsDIR
sshfsDIR="$sshfs_LOCALDIR"




###################################################### 20200911>@~~~ postparse-repeats? move/clarify/use-Lforlocalrun

### NOTE: DISABLED above set doREMOTE on param1 root@ip>>> postparse on -L etc.. or multiconditions etc. LEAVEON here print?

if [ "${doREMOTE}" == "n" ]; then #20200911 COMMENT: n preparse? echo -q grep? removed? nope was set on no param1 root@x
    #ecmd "sendit > " #echo -n "sendit > "
	#oscheck2
	if booloscheck; then
		ecmd "payload-run"
		sendit="n"
	else
		#could set defaultsonhostvarhere
		ecmd "payload-setup"
		sendit="y"
	fi
fi




	#######################################################################
	while [ "$#" -gt 0 ]; do
	case "$1" in
    -h) usage;
	exit 0;;
    --help) usage;
	exit 0;;
    ##################################################
    -z) BBUG="y";
	echo "full debug enabled"
	if [ "$2" == "file" ]; then
		BBUGF="./debugfile.txt"
		echo "Outputfile: $BBUGF"
		shift 2
	else
		shift 1
	fi
	;;
    ##################################################
    -f|force) force="y"; shift 1; ;; #for exportservice
    flash)
        #more checks name/model + size etc...
        SYSUPF="$2"; shift 2
        if [ "$SYSUPF" = "latest" ]; then
            findlatestimg #|| exit
            if [ ! -z "$LATESTIMG" ]; then
                    SYSUPF="$LATESTIMG"
                    #echo "latest: $(dirname $LATESTIMG)" && sleep 2
                    #echo "latest: $(dirname $LATESTIMG)" && sleep 5 #echo "latest: $LATESTIMG [peek-timeout-3]" && sleep 3
            else
                echo "latest [no-LATESTIMG]" && exit 0
            fi
        fi
	    if [ ! -f "$SYSUPF" ]; then echo "$0 flash $SYSUPF [no-file]"; exit 1; fi
        DOFLASHSYSUP=1
    ;;

    factorytodisk)
        #echo "warning factory to disk experimental"; sleep 2
        if [ -z "$2" ]; then echo "$0 factorytodisk <factory.img.gz><<<[please-add-factory-image]"; exit 1; fi
	    if [ ! -f "$2" ]; then echo "$0 factorytodisk <factory.img.gz> [invalid]"; exit 1; fi
        FACTORYF="$2"; #shift 2
	    if [ -z "$3" ]; then echo "$0 factorytodisk $FACTORYF /dev/sdX <<<[please-add-output-disk]"; exit 1; fi

        if [ ! -b "$3" ]; then echo "$0 factorytodisk $3 [invalid-disk]"; exit 1; fi #@!!!SDCARDREADERthinksTHEREis-bwhenREMOVED
        #grep -Ff <(hwinfo --disk --short) <(hwinfo --usb --short)
        oDISK="$3"; shift 3

        case "$FACTORYF" in
            *".img.gz")
                echo "dd if=/dev/zero of=$oDISK bs=4096 status=progress"
                echo "zcat $FACTORYF | dd of=$oDISK bs=4096 status=progress; sync"
                exit 0
            ;;
            *".img")
                echo "dd if=/dev/zero of=/dev/$oDISK bs=4096 status=progress"
                echo "DBGtestcmd time dd if=$FACTORYF of=$oDISK bs=4096 status=progress; sync"
                echo "time $(zcat $FACTORYF | dd of=$oDISK bs=4096 status=progress; sync)"
                exit 0
            ;;
            *)
                echo "factory: $FACTORYF [format-unknown]" && exit 11
            ;;
        esac

        echo "end-here"; exit 0
    ;;
    targzdo)
        : #TARFILE="rtrCONF/dca632563177/backup.tar.gz"
    ;;
    -M)
		which sshfs &>/dev/null || echo "sshfs is not installed"
		which sshfs &>/dev/null || exit 1
		#sshfsmounty # need to pass dir to this andmaybe sshfsREM
		sshfsmounty "mount" "$sshfsREM" "$sshfs_LOCALDIR"
		exit 0
		#shift 1;
	;;

	-UM)
		sshfsmounty "umount" "$sshfsREM" "$sshfs_LOCALDIR"
		exit 0
	;;

    -c)
    shift

    echo "grep -q \"\$(basename \$0)\" /proc/\$PPID/cmdline"
    echo "grep -q "$(basename $0)" /proc/$PPID/cmdline"

    if grep -q $(basename $0) /proc/$PPID/cmdline; then
        echo "SELFCALL"
    fi

    #echo "1: $1"
    #exit 0
    if [ -f "$1" ]; then
        doCOMMANDfile=y
        CMDFILE="$1"
    else
        doCOMMAND="y";
        docmd="$@";
    fi
    #shift 1;
	break
	;;

    -opkgrestore)
	#needs conntest PLUS opkg update += test tooTOBEWRITTENorinFUNCBELOW
	rtrpkgrestore "$rUSER@$ROUTERIP" "$2"
	exit 0
	;;
    -opkgdump)
	if [ ! -z "$2" ]; then PKGLIST="$2" && shift 2; else shift 1; fi
	doopkgdump="y"
	;;
    confbackup)
	dosysupget="y"
	shift 1
	;;
    confrestore)
	if [ -z "$2" ]; then echo "-sysupput NEEDFILE" && exit 1; fi
	if [ ! -f "$2" ]; then echo "-sysupput FILEINVALID: $2" && exit 1; fi
	RESTOREFILE="${2}"
	dosysupput="y"
	shift 2
	;;
    -wifiC)
	dowifiC="y"
	shift 1
	;;

    ############################################# removed exportservice

    -*|*)
	echo "unknown option: $1 ... \
	need: -d dotno -s slpsec -n nonew" >&2;
	usage
	exit 1;;
    ###############!!!!!!!!!!!!!!!!!! WASOFF-WHY??? >>> $0 lsof (aka wrong param hangs)
    #*) usagerestore; exit 1;;
  esac
done


    #-S) doBsys="y";
#	Psfile=$(basename $2)
#	SDIR=${2%/*}
#	Sext=${2##*.}
#	echo "parse> -S Pofile: $Psfile  SDIR:$SDIR Pext:$Sext"





################################################# REASON @ PARSEBELOW >>> UPPERonelikelydupeforearlyBBGING 'mini-ecmdcalls'

###FIX ? changevaronlylowerandprint?

##################################################
#    -z) BBUG="y";
#	echo "full debug enabled"
#	if [ "$2" == "file" ]; then
#		BBUGF="./debugfile.txt"
#		echo "Outputfile: $BBUGF"
#		shift 2
#	else
#		shift 1
#	fi
#	;;
##################################################


if [ "$BBUG" == "y" ]; then
	if [ -z "$BBUGF" ]; then
		ecmd() { echo $1; sleep 1; }
	else
		ecmd() { echo $1 >> $BBUGF; }
	fi
else
	ecmd() { echo $1 > /dev/null; }
fi








eslp=1

showsettings() { #DEBUGprint and FAIL header

cat <<EvP
                           #######################
      REMOTEUSER/ROUTERIP: ${rUSER}@${ROUTERIP}
                           #######################
EvP

}




whoops() { #20200903>postparse-or-foundation-routine-runningrepeatcall-and-check/report issues???
if [ ! -z "$runissue" ]; then
    showsettings
    cat /tmp/$(basename $0).issues
    echo "please rm /tmp/$(basename $0).issues"
    exit 0
    #else [ -n "$DEBUG" ] && echo "everythingok $1"
fi
} #echo "HORSE"; exit 0







#if ! checkupandsshport "$ROUTERIP"; then echo "host $ROUTERIP down or no ssh" && exit 1; fi
#[ -n "$DEBUG" ] && echo "Checking $ROUTERIP is alive" && sleep ${eslp:-2}
if ! checkupandsshport "$ROUTERIP"; then
    sshmsg="${sshmsg} [notalive]"
    runissue=1
    echo "host $ROUTERIP down or no ssh" >> /tmp/$(basename $0).issues
    #echo "host $ROUTERIP down or no ssh" && exit 1
########## 202009notused
else
    alivecheck=1
    #disable top "abouttocheck and appendthistosshmsg"
    sshmsg="${sshmsg} [alive]"
fi



#if [ ! -z "$DEBUG" ]; then
#    showsettings
#fi







#printthisbecauseremovedstraightexitabove>runissues
#if [ -z "$alivecheck" ]; then
#    echo "host not checked for alivelyness!"
#fi


whoops "alive" #@! -z "$runissue"





#AKEYS="/etc/dropbear/authorized_keys"
#rUSER="root"

if ! checksshaccess "$ROUTERIP" 2>/tmp/sshaccesserr; then

    sshmsg="${sshmsg} keyauth-check [nope>setup/invalid-user]"

    if cat /tmp/sshaccesserr | grep -q 'Offending'; then
		sshmsg="$sshmsg Host key has changed"
		#echo "ssh-keygen -f \"${HOME}/.ssh/known_hosts\" -R ${ROUTERIP}"; sleep 2
		ssh-keygen -f "${HOME}/.ssh/known_hosts" -R ${ROUTERIP} 2>/dev/null 1>/dev/null
	fi

    echo "host $rUSER@$ROUTERIP $sshmsg please enter password to add key"


	ssh $rUSER@$ROUTERIP "tee -a $AKEYS" < ${HOME}/.ssh/id_rsa.pub > /dev/null
	#	ssh $RTR "cat $AKEYSr | uniq > /tmp/keys"
	#	ssh $RTR "cat /tmp/keys > /etc/dropbear/authorized_keys"
	if [ $? -eq 0 ]; then
		sshmsg="$sshmsg ssh-key-pushed" #NEW
		echo "SSH KEY HAS BEEN PUSHED"
    else
		sshmsg="$sshmsg ssh-key-pushissue" #NEW
        #############@@@~20200910-showinfo/abort-whenthisfails
        #echo "nanoo-nanoo"
        runissue=1
        echo "KEYPUSH> $rUSER@$ROUTERIP $AKEYS < ${HOME}/.ssh/id_rsa.pub [failed]" >> /tmp/$(basename $0).issues
        echo "KEYPUSH> note:wip false-positive?" >> /tmp/$(basename $0).issues
        #echo "KEYPUSH> note:wip maybe false-positive/notifybutdontsetrunissue [failed]" >> /tmp/$(basename $0).issues
    fi


########################## 202009-showdebugstatus>>>afterstanzaallinfofailorsuccess sshmsg commandeeredforallmsgsnotjustfail
#else
#    [ -n "$DEBUG" ] &&
#    echo "host $rUSER@$ROUTERIP $sshmsg SOMETHINGSOMETHINGSOMETHING"
else
    sshmsg="${sshmsg} keyauth-check $rUSER@$ROUTERIP [ok]" #NEW
###################################################################################


fi



[ -n "$DEBUG" ] && echo "$sshmsg"



whoops "keycheck" #@! -z "$runissue"


###################echo "host $ROUTERIP down or no ssh" >> /tmp/$(basename $0).issues
#@@@NOW-whoops
#if [ ! -z "$runissue" ]; then cat /tmp/$(basename $0).issues; exit 0; fi
#echo "HORSE"; exit 0








#if [ "$dbgthresh" -gt 2 ]; then
#echo "Checking for infofile: $1"; sleep 1;
#fi




checkforinfofile() {

	if [ "$dbgthresh" -gt 2 ]; then
        echo "Checking for infofile: $1"; sleep 1;
    fi

	ssh $rUSER@$ROUTERIP "test -f $1"; retVAL="$?"
	if [ $retVAL -ne 0 ]; then
		echo " [no infofile: $1]"; #return 5
		ssh $rUSER@$ROUTERIP "echo rtrSIG=\"$rtrSIG\" >> $1"
		ssh $rUSER@$ROUTERIP "echo installDATE=\"$D\" >> $1"
		ssh $rUSER@$ROUTERIP "echo importSIG=\"${ROUTERMAC}-$D\" >> $1"
		ssh $rUSER@$ROUTERIP "ubus call system board >> $1"
		#ssh $rUSER@$ROUTERIP "cat $1"
	else
	    if [ "$dbgthresh" -gt 2 ]; then echo "[ok]"; fi
		#######if [ "$dbgthresh" -gt 2 ]; then ssh $rUSER@$ROUTERIP "cat $1"; sleep 2; fi
	fi


#################importSIG=$(ssh $rUSER@$ROUTERIP "cat $1" | grep importSIG | cut -d'"' -f2)
#importSIG=$(ssh $rUSER@$ROUTERIP "cat $1 | grep importSIG " | cut -d'=' -f2)
#echo "importSIG: $importSIG"

#ubus -S call system board | jsonfilter -e '@.release.description'

#MODEL=$(cat /etc/board.json | jsonfilter -e '@["model"]["id"]')
#WIFINIC0="wlan0"
#WIFINIC1="wlan1"
#MACADDR=$(cat /sys/class/net/$NIC/address | sed -e 's/://g')
#MACADDRwlan0=$(cat /sys/class/net/$WIFINIC0/address | sed -e 's/://g')
#MACADDRwlan1=$(cat /sys/class/net/$WIFINIC1/address | sed -e 's/://g')


}








ecmd() {
    echo "${*}"
    sleep 1
}


pruneDstring() { #v2.1 pruneDstring "./synowrt/diffdata/*-*" "3"

fstring="${1}"; KEEPNUM="${2}"; newkeepnum=$(($KEEPNUM + 1))
ecmd "pruning backups to pruneno: $pruneNOB" 0 6
ecmd "newkeepnum: $newkeepnum" 0 6
left="`find $fstring -maxdepth 0 -mindepth 0 -type d -exec echo {} \; | wc -l`"
if [ "$left" -gt "${KEEPNUM}" ]; then
	ecmd " $left ismorethan $KEEPNUM " 0 6 #ecmd "$left is great"
	find $fstring -maxdepth 0 -mindepth 0 -type d -exec echo {} \; > /tmp/cDlist
	trashing=`cat /tmp/cDlist | tail -n $newkeepnum | head -n 1`
	for f in $trashing; do
		if [ -f "$f/etc/hosts" ]; then echo "ROOTPANICK" && exit; fi
		ecmd "Deleting \"$f\"" 0 1
		rm -rf "$f"
	done
	left="`find $fstring -maxdepth 0 -mindepth 0 -type d -exec echo {} \; | wc -l`"
	ecmd "Num remain: $left" 0 6
	pruneDstring "$fstring" "$KEEPNUM"
fi
}

prunetospace() {

fstring="${1}";
maxspace="${2}";
#@@@
pruneMAXkb=$(($maxspace * 1000))
#ORIGINALFAULTY spaceused=$(du -cs `dirname $fstring` | tail -n 1 | tr -s "\t" " " | cut -d' ' -f1) #+ dirname 1 2 3
spaceused=$(du -cs ${1} | tail -n 1 | tr -s "\t" " " | cut -d' ' -f1)
spaceusedMB=$(($spaceused / 1000));
numleft="`find $fstring -maxdepth 0 -mindepth 0 -type d | wc -l`"


#!!!@@@if -z below
#pruneSNAPS=1; pruneMAXmb="2230"; pruneMAXkb=$(($pruneMAXmb * 1000))
#pruneBINOUT=1; pruneBINOUTMAXmb="2230"; pruneBINOUTMAXkb=$(($pruneBINOUTMAXmb * 1000))
#pruneNOB="3"


if [ "$3" != "repeat" ]; then
	######ecmd "Checking space consumption: `du -chs \`dirname $fstring\` | tr -s "\t" " " | cut -d' ' -f1`" 0 0
	#echo "spaceused: $spaceused prunemaxkb: $pruneMAXkb"
	#ecmd "Checking space consumption: `dirname $fstring | head -n 1` dirs:$numleft" 0 0
	#ecmd "dirs:$numleft spaceusedMB: $spaceusedMB" 0 0
	:
fi



if [ "$pruneMAXkb" -lt "$spaceused" ]; then
	#echo "prune: overspace"
	ecmd "space [over] dirs:$numleft spaceusedMB: $spaceusedMB" 0 0
	trashing="`find $fstring -maxdepth 0 -mindepth 0 -type d | head -n 1`"
	if [ ! -z "$trashing" ]; then
		if [ -f "$trashing/etc/hosts" ]; then echo "ROOTPANICK" && exit; fi
		ecmd "Deleting \"$trashing\"" 0 1; rm -rf "$trashing"
		prunetospace "$1" "$2" "repeat" #prunetospace "$1" "$2"
	fi
else
	ecmd "space [ok] snapdirs: $numleft spaceusedMB: $spaceusedMB" 0 0
fi
}

############################################################################# Pruning...[move] >~cleanup-success
#fstring="$ib_root/$PROFILEn/binout/*" #fstring="$ib_root/$PROFILEn/binout/*-*"
#if [ ! -z "$pruneBINOUT" ]; then
#	if [ ! -z "$pruneBINOUTMAXmb" ]; then
#		ecmd "Pruning $fstring backups to space: $pruneBINOUTMAXmb" 2 3; prunetospace "$fstring" "$pruneBINOUTMAXmb"
#	else
#		ecmd "pruning $fstring backups to pruneno: $pruneBINOUTNOB" 2 3; pruneDstring "$fstring" "$pruneBINOUTNOB"
#	fi
#fi











################################################################################################detectcallesas() {}
#######cmdPATH="/fs/sdd1/openwrt/RTNGext/FAKEcmds"; cmdS="$cmdPATH/runmake_dosshVERSION5.sh"; $cmdS -c ubus "${*}"
cmdPATH=$(dirname $0)
cmdSCRIPT=$(basename $0); #$cmdPATH/$cmdSCRIPT -c ubus "${*}"
#case "$cmdSCRIPT" in
#ubus)
#;;
#uci)
#;;
#esac








rtrsiggen #sets ROUTERMAC and rtrSIG[ip+mac] > locally
rtrMODEL=$(ssh $rUSER@$ROUTERIP "cat /tmp/sysinfo/board_name" | sed 's/,/./g')
#rtrSIG is same? localSIG="$rtrMODEL-$ROUTERMAC" #echo "localSIG: $localSIG" #this is local DIR2 just model+mac
#ubus -S call system board | jsonfilter -e '@.release.description'



checkforinfofile "/system.info" #TBA then source it too
#INcreatesystem.info-fuction if [ "$dbgthresh" -gt 2 ]; then echo "Checking for infofile: $1"; sleep 1; fi




#@@@+20200737<-confbackup()shouldbehere->FLASHSYSUP
rtrOUTd="$rtrCONFd/$ROUTERMAC" #echo "rtrOUTd=$rtrCONFd/$ROUTERMAC"






if [ "$dbgthresh" -gt 2 ]; then
	echo "         rtrMODEL: $rtrMODEL"
	echo "           rtrSIG: $rtrSIG"
	sleep 2
fi







if [ ! -z "$DOFLASHSYSUP" ]; then

    SYSUPCMD="sysupgrade -v"


    echo "unshiftedPARAMS: ${*}"; #sleep 5

    case "$rtrMODEL" in

        *"4-model-b"*)
            #SYSUPCMD="${SYSUPCMD} -p "

            #echo "NOTE: testing -R AUTORESTORE@communitysysupgrade@sbin-sysupgrade+-k>###AUTO>/etc/backup/installed_packages.txt"

            echo "manually not passing -R"; sleep 2
            SYSUPCMD="${SYSUPCMD} -p " #-v is on all
            #echo "manually passing -R"; sleep 2
            #SYSUPCMD="${SYSUPCMD} -p -R" #-v is on all
        ;;

        *)
            SYSUPCMD="${SYSUPCMD} -n "
        ;;
    esac


    ####################################################################
    #echo "Setting sysupgrade cmd: $SYSUPCMD rtrMODEL: $rtrMODEL"
    #echo "sysupgrade-cmd: $SYSUPCMD"; sleep 2
    #echo "||| warning experimental $SYSUPCMD $SYSUPF |||"; sleep 2
    ####################################################################
    #echo "||| warning experimental |||"; #sleep 2
    ####################################################################
    echo "$rtrMODEL"
    echo "|||     DIR: $(dirname $LATESTIMG)"
    echo "||| SYSFILE: $(basename $SYSUPF)";
    echo "|||  SYSCMD: $SYSUPCMD"; #sleep 2
    echo ""
    sleep 2


fi









if [ "$doCOMMAND" == "y" ]; then
	ssh $rUSER@$ROUTERIP $docmd
	#echo "$?"
	exit 0
fi





if [ "$doCOMMANDfile" == "y" ]; then
    #ssh $rUSER@$ROUTERIP 'bash -s' < $CMDFILE #$docmd
    #cat $CMDFILE | ssh $rUSER@$ROUTERIP 'bash -s'
    #plink root@MachineB -m local_script.sh
    #udo, run ssh root@MachineB 'echo "rootpass" | sudo -Sv && bash -s' < local_script.sh

    #ssh user@host ARG1=$ARG1 ARG2=$ARG2 'bash -s' <<'ENDSSH'
    #  # commands to run on remote host
    #    echo $ARG1 $ARG2
    #ENDSSH


    #ssh root@MachineB 'bash -s -- uno' < local_script.sh


    cat $CMDFILE | ssh $rUSER@$ROUTERIP 'bash -'
    #echo "$?"
	exit 0
fi





if [ "$doopkgdump" == "y" ]; then
	echo "NEEDS just dump rom or dump all with locations"; sleep 3
	rdopkglist "$rUSER@$ROUTERIP" #rdopkglist "$rUSER@$ROUTERIP" NOTUSINGTHIS"$2"
fi





#@@@!!! echo "DEBUG: WHATIS \$2: $2 RERUN WITH sysuprestore||or||gettotest-WITHTHOSE-TOO"
#if [ "$dosysupget" == "y" ]; then sysupgradebackup "$rUSER@$ROUTERIP" "$2"; fi
#if [ "$dosysupput" == "y" ]; then sysupgraderestore "$rUSER@$ROUTERIP" "$2"; fi
if [ "$dosysupget" == "y" ]; then


    echo "unshiftedPARAMS: ${*} DEBUG-2: $2"
    #sleep 5

    sysupgradebackup "$rUSER@$ROUTERIP" "$2"

fi


if [ "$dosysupput" == "y" ]; then


    echo "unshiftedPARAMS: ${*} DEBUG-2: $2"


    sysupgraderestore "$rUSER@$ROUTERIP" "$2"

fi

#echo "DEBUG: WHATIS \$2: $2 EXIT"; exit 0









FLASHKEEPCONFBACKUP=1 #MOVETOPOSTPARSE/TOP/BOTH ONLYCOPY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
######################## FLASHKEEPIMG=1 #REPEATOFSOMETHINGHIGHER DUPEOVERRIDELOWER!!!!!!!!!!!!!!!!!!!!!!!!!
######################## TESTSKIP
#FLASHKEEPCONFBACKUP=
####BELOWISSETON-HIGHERUP-DONTREALLYNEEDTHISFORNOW
FLASHKEEPIMG=



if [ ! -z "$DOFLASHSYSUP" ]; then





keepflashedimgcopy() {


    FLASHKEEPDIR="$rtrCONFd/$rtrSIG-flashedimages"; mkdir -p "${FLASHKEEPDIR}"
    NEWNAMEPFX="$D-$(ls -rt "$BUILDSLOCALD/" | tail -n1)_$(basename $SYSUPF)"

    if [ ! -d "${FLASHKEEPDIR}" ]; then
        echo "Creating... ${FLASHKEEPDIR}"; mkdir -p "${FLASHKEEPDIR}"
    fi; sleep 2

    if [ ! -z "$FLASHKEEPIMG" ]; then #rtrOUTd="$rtrCONFd/$ROUTERMAC" #echo "rtrOUTd=$rtrCONFd/$ROUTERMAC"; exit 0

        echo "||| keep img copy"
        sleep 2

        echo "   imgname: $NEWNAMEPFX"
        echo "    imgdir: $FLASHKEEPDIR"
        #DBG echo "   savefullpath: $FLASHKEEPDIR/$NEWNAMEPFX"
        #DBG echo "cp $rtrOUTd/backup.tar.gz $FLASHKEEPDIR/$NEWNAMEPFX-pre-backup.tar.gz"

        cp $rtrOUTd/backup.tar.gz $FLASHKEEPDIR/$NEWNAMEPFX-pre-backup.tar.gz || exit 3

    fi; #sleep 3

}




flashkeepconfbackup() {


    if [ ! -z "$FLASHKEEPCONFBACKUP" ]; then

        [ -n "$DEBUG" ] && echo "backupconfig: $0 confbackup"
        echo "||| backup router config"; sleep 2
        $0 confbackup; RETCBACK=$?
        if [ "$RETCBACK" -ne 0 ]; then
            echo "problemo" && exit 33
        fi
        sleep 2
        #RETCBACK = 2 = FAIL!!!

    else
        [ -n "$DEBUG" ] && echo "flashkeepconfbackup [disabled]"
    fi

}




    if ! echo "$SYSUPF" | grep -q '\-sys'; then echo "$(basename $SYSUPF) not-a-sysupgrade"; exit 1; fi



    #NOTE!@@@ this is just creating the backup...
    flashkeepconfbackup #FLASHKEEPCONFBACKUP=1

    #NOTE!@@@ this is afterthe flash below... this is copying the backup
    keepflashedimgcopy #returns@-z"$FLASHKEEPIMG"





    #@@@FUNCTIONPLUS-LOTS-OF-return 1 checks each variable/step!!!!!!!!!!!!!!!!!!!!!! MAYASWELLCALLBEFOREBACKUPS/IMGKEEP


    echo "||| Validate img signature..."; sleep 2


    strings $SYSUPF | tail -n3 | grep 'metadata' > /tmp/imgmetastr
    IMGMETAboardf=$(cat /tmp/imgmetastr | sed 's|.*supported_devices||g' | cut -d'[' -f2 | cut -d']' -f1 | cut -d'"' -f2)
    rtrMODELcomma=$(echo $rtrMODEL | sed 's/\./,/g')
    #echo "rtrMODEL:$rtrMODELcomma imgMETA: $IMGMETAboardf"; echo ""


    if [ "$IMGMETAboardf" != "$rtrMODELcomma" ]; then
        echo "IMAGE: $(basename $SYSUPF) j:$IMGMETAboardf b:$rtrMODELcomma [incompatible]"
        exit 0
    else
        echo "IMAGE: $(basename $SYSUPF) j:$IMGMETAboardf b:$rtrMODELcomma [compatible]"
        : #echo "IMAGE: $(basename $SYSUPF) j:$IMGMETAboardf b:$rtrMODELcomma [compatible]"
    fi
    #echo "SCOOBYDIVE"; exit 0





    echo ""
    echo "||| Flashing $ROUTERIP with $(basename $SYSUPF)"
    #echo ""
    sleep 1



    #echo "#######################################################"
    echo "scp $(basename $SYSUPF) $rUSER@$ROUTERIP:/tmp/sysupgrade.img.gz"
    #echo "ssh $rUSER@$ROUTERIP 'sysupgrade -v -p /tmp/sysupgrade.img.gz'"
    echo "ssh $rUSER@$ROUTERIP \"$SYSUPCMD /tmp/sysupgrade.img.gz\""
    #echo "#######################################################"
    echo ""
    echo -n "ctrl-c to cancel: "; sleep 2;
    echo -n "."; sleep 1.1; echo -n "."; sleep 0.9; echo -n "."; sleep 0.7; echo -n "."; sleep 0.5; echo -n "."; sleep 0.3
    #echo -n "."; sleep 1.5; echo -n "."; sleep 1.3; echo -n "."; sleep 1.1; echo -n "."; sleep 1; echo -n "."; sleep 0.9
    echo -n "."; sleep 0.7
    echo " [go]"


    NOCONFIRM=1
    if [ ! -z "$NOCONFIRM" ] || [ -f "./.noconfirm" ]; then
        echo "confirm-skip"
    else
        pleaseConfirm || exit $?
    fi
    #echo "SCOOBYDOO"; exit 0


    scp $SYSUPF $rUSER@$ROUTERIP:/tmp/sysupgrade.img.gz; RETSEND=$?
    echo "sent[$RETSEND]"; sleep 1 #0



    #echo "ssh $rUSER@$ROUTERIP \"$SYSUPCMD /tmp/sysupgrade.img.gz\""
    #echo "LIME"; exit 0
    ssh $rUSER@$ROUTERIP "$SYSUPCMD /tmp/sysupgrade.img.gz"; RETSYSUP=$?
    echo "sysupcmd [$RETSYSUP]" #255




    if [ ! -z "$FLASHKEEPIMG" ]; then
        #@echo
        cp -af "${SYSUPF}" "${FLASHKEEPDIR}/${NEWNAMEPFX}"
    fi



	#######################################################################################################


    pruneBINOUT=1; pruneBINOUTMAXmb="5230"; pruneBINOUTMAXkb=$(($pruneBINOUTMAXmb * 1000))
    pruneBINOUTNOB="10"
	fstring="$rtrOUTd/*" #fstring="$ib_root/$PROFILEn/binout/*-*"

	#if [ ! -z "$pruneBINOUT" ]; then
	#	if [ ! -z "$pruneBINOUTMAXmb" ]; then
	ecmd "pruning $fstring backups to pruneno: $pruneBINOUTNOB" 2 3
	pruneDstring "$fstring" "$pruneBINOUTNOB"
	ecmd "Pruning $fstring backups to space: $pruneBINOUTMAXmb" 2 3
	prunetospace "$fstring" "$pruneBINOUTMAXmb"
	#	fi
	#fi


fi
######################## WASONHARDCODED NOTE: -R technically no used... adds ### AUTO(ignored)... -k is hardcoded on
#echo "NOTE: testing -R (THISTIMENOTSENDING) AUTORESTORE in /etc/backup/installed_packages.txt"





if [ "$dowifiC" == "y" ]; then wifistationshow; fi #ssh $rUSER@$ROUTERIP wifistationshow
exit 0






#####################################################################################################











############### case input
    -exportservice)
		#exportservice "adblock"
		#exit 1
		if [ "$2" == "adblock" ] || [ "$2" == "banip" ]; then
			serviceE="$2"; shift 2;
		else
			usage && exit 1
		fi
		;;
################## MAIN-REMOVE-INFREQUENTUSE
if [ ! -z "$serviceE" ]; then exportservice "$serviceE"; exit 0; fi
#####################################################################################################

















#####################################################################################################
#post-parse self-call 20200730@before run sysup-img... never worked
#####################################################################################################
#####################################################################################
    #-S) doBsys="y";
#	Psfile=$(basename $2)
#	SDIR=${2%/*}
#	Sext=${2##*.}
#	echo "parse> -S Pofile: $Psfile  SDIR:$SDIR Pext:$Sext"
#####################################################################################
###################################### FAULTYputupin-cmaybe
#if [ ! -f "/tmp/hum" ]; then
#    echo "selfcalltest: /tmp/hum"
######    #sh $0 -c uname -a
#    $0 -c 'uname -a'
#    touch /tmp/hum
#    exit 0
#else
#    echo "skipselftest: /tmp/hum"
#    #exit 0
#fi
#####################################################################################
############## fakeuser set -x
#set -x
############## hmmm... had no effect... static-root/keybypass~
#+ '[' dca632563177 == 000000000000 ']'
#+ rtrSIG=dca632563177-10.2.3.1
#++ ssh root@10.2.3.1 'cat /tmp/sysinfo/board_name'
#++ sed s/,/./g
#+ rtrMODEL=raspberrypi.4-model-b
#+ checkforinfofile /system.info
#+ '[' 1 -gt 2 ']'
#######################################################################################
#####################################################################################################










#M=$(cat /sys/class/net/br-lan/address | cut -d : -f 1- | sed -e 's/://g')




#?if ! echo "$SYSUPF" | grep '-sys' | grep -q 'ext4'; then echo "$(basename $SYSUPF) not-a-sysupgrade"; exit 1; fi
#LAST if ! echo "$SYSUPF" | grep -q 'sysupgrade'; then echo "$(basename $SYSUPF) not-a-sysupgrade"; exit 1; fi
#if ! echo "$SYSUPF" | grep -q '.tar.gz'; then echo "$(basename $SYSUPF) not-a-targz"; exit 1; fi







	#######################################################################################################
    #set -x #needed ecmd()
    #pruneNOB="3"
    #pruneSNAPS=1; pruneMAXmb="70"; pruneMAXkb=$(($pruneMAXmb * 1000))
	#######################################################################################################
    #fstring="$rtrOUTd/*" #fstring="$ib_root/$PROFILEn/binout/*-*"
    #pruneBINOUT=1; pruneBINOUTMAXmb="5230"; pruneBINOUTMAXkb=$(($pruneBINOUTMAXmb * 1000))
    #pruneBINOUTNOB="10"
	#######################################################################################################
    #@@@NOTE: MAXkb-nowinternaltofunction #pruneSNAPS=1; pruneMAXmb="2230"; pruneMAXkb=$(($pruneMAXmb * 1000))







#ssh $rUSER@$ROUTERIP "ubus call system board"
#ssh $rUSER@$ROUTERIP "ubus call system board | jsonfilter -e '@[\"release\"][\"version\"]'"

echo ""
echo "HOSTNAME-date-F: ${HOSTNAME}-$(date +%F).tar.gz"; sleep 3
echo ""

ssh user@host <<-'ENDSSH'
    #commands to run on remote host
    ssh user@host2 <<-'END2'
        # Another bunch of commands on another host
        wall <<-'ENDWALL'
            Error: Out of cheese
        ENDWALL
        ftp ftp.secureftp-test.com <<-'ENDFTP'
            test
            test
            ls
        ENDFTP
    END2
ENDSSH

#####################################################################################################
#nc -q0 192.168.1.1 1234 < openwrt-ar71xx-tl-wr1043nd-v1-squashfs-sysupgrade.bin
#On the OpenWrt device, run:
#nc -l -p 1234 | mtd write - firmware
###########################################################################################################
#/usr/bin/ssh -x -oForwardAgent=no -oPermitLocalCommand=no50 #opkg openssh-client
###################################################################################################################
#ubus -S call system board | jsonfilter -e '@.release.description'
#ssh root@ROUTERIP "logread -f | grep -vE '(my_script.sh|AP-STA)'" | tee -a /tmp/router.log | nc -v -u -w 0 LOGSERVER 514
################################################################################################################
#parted /dev/sdh --script print devices #needs device but just showing all
####################################################################
#sudo dd if=/dev/zero of=/dev/sdb bs=4096 status=progress
#sudo dd if=/dev/zero of=/dev/sdb bs=1k count=2048; #time dd if=/dev/zero of=/dev/sdh bs=1k count=2048
####################################################################
#sudo parted /dev/sdb --script -- mklabel msdos
#sudo parted /dev/sdb --script -- mkpart primary fat32 1MiB 100%
#sudo mkfs.vfat -F32 /dev/sdb1
#sudo parted /dev/sdb --script print
####################################################################
#sudo parted /dev/sdb --script -- mklabel gpt
#sudo parted /dev/sdb --script -- mkpart primary ext4 0% 100%
#sudo mkfs.ext4 -F /dev/sdb1
#sudo parted /dev/sdb --script print
####################################################################
#sudo umount /dev/sdb -l
####################################################################
#time dd if=/dev/zero of=/dev/sdh bs=4096 status=progress
#SAMSUNGEVO=32G=15mins@zero-w32Mbfactory~1.5minsMAX
################################################################################## default
#root@zr:/fs/sdd1/openwrt/RTNGext/cache/rpi4/builds# parted /dev/sdh --script print
#Model: Generic STORAGE DEVICE (scsi)
#Disk /dev/sdh: 32.0GB
#Sector size (logical/physical): 512B/512B
#Partition Table: msdos
#Disk Flags:
#
#Number  Start   End     Size    Type     File system  Flags
# 1      4194kB  407MB   403MB   primary  fat16        boot, lba
# 2      411MB   1418MB  1007MB  primary  ext2
############################################################################################
#diskpartnum=$(parted /dev/sdh --script print | grep -A30 Number | grep -v 'Number' | grep -v '^$' | wc -l)
#sudo parted /dev/sdh --script -- mkpart primary ext4 100%
##################################################################################
#parted ${dev} --script mkpart primary $partTP4 $partSZ3 $partSZ4 &>/dev/null
#sync; partprobe; sleep 1
#mkfs.$partTP1 -L $partLB1 ${dev}1 1>/dev/null
#mkfs.$partTP1 -L $partLB1 ${dev}1 &>/dev/null
####################################################### pv
#############Copy /dev/sda to to /dev/sdb:
#pv -tpreb /dev/sda | dd of=/dev/sdb bs=64M
#OR
#pv -tpreb /dev/sda | dd of=/dev/sdb bs=4096 conv=notrunc,noerror
#sudo dd if=/dev/sdb | pv -s 2G | dd of=DriveCopy1.dd bs=4096
#pv /home/user/bigfile.iso | md5sum
##hwinfo #grep -Ff <(hwinfo --disk --short) <(hwinfo --usb --short)
#watch -n5 'sudo kill -USR1 $(pgrep ^dd)'
#sudo kill -USR1 $(pgrep ^dd)







#@@@ib.ini maybe...
BUILDSLOCALD="/fs/sdd1/openwrt/RTNGext/cache/rpi4/builds"; if [ ! -d "$BUILDSLOCALD" ]; then BUILDSLOCALD= ; fi

if [ -d "$BUILDSLOCALD" ]; then

    DIRTOSEARCH=$(ls -rt "$BUILDSLOCALD")
    if [ ! -d "$DIRTOSEARCH" ]; then echo "dirtosearch: $DIRTOSEARCH [notdir]" && exit 0; fi

    #TESTDEPTH1
    LATESTIMG=$(find "$BUILDSLOCALD/$DIRTOSEARCH/" -maxdepth 1 -mindepth 1 -type f | grep ext4 | grep '-sys' | tail -n1)


    [ -n "$DEBUG" ] && echo "find \"$BUILDSLOCALD/$DIRTOSEARCH/\" -maxdepth 1 -mindepth 1 -type f | grep ext4 | grep '-sys' | tail -n1"

    if [ ! -f "$LATESTIMG" ]; then echo "latestimg: $LATESTIMG [notfile]" && exit 0; fi

fi







####PREDEPTHLATESTIMG=$(find "$BUILDSLOCALD/$DIRTOSEARCH/" | grep ext4 | grep '\-sys')
#ORG LATESTIMG=$(find "$BUILDSLOCALD/$DIRTOSEARCH/" | grep ext4 | grep sysupgrade)
# LATESTIMG=$(find "$BUILDSLOCALD/$DIRTOSEARCH/" | tail -n1 | grep ext4 | grep '-sys')
#RIGHTwORNAMES LATESTIMG=$(find "$BUILDSLOCALD/$DIRTOSEARCH/" | tail -n1) | grep ext4 | grep sysupgrade)
#nope? LATESTIMG=$(find "$BUILDSLOCALD/$DIRTOSEARCH/" | tail -n1 | grep ext4 | grep '-sys')
#######@@@needs > tmp cat | reverse | read if -f continue || ls -rt + -D
######@@@-d -g -F -H
#LATESTIMG=$(find $BUILDSLOCALD/$(ls -rt "$BUILDSLOCALD/" | tail -n1) | grep ext4 | grep sysupgrade)
#echo "LATESTIMG: $LATESTIMG"
#exit 0
#if [ -d "$BUILDSLOCALD" ]; then LATESTIMG=$(find $BUILDSLOCALD/$(ls -rt "$BUILDSLOCALD/" | tail -n1) | grep ext4 | grep sysupgrade); fi
#echo $(ls -rt "$BUILDSLOCALD/" | tail -n1)
#cat "$(ls -rt /tmp/speedtestResult/*.log | tail -n1)" | grep -i upload | tr -d "Avg: " | tr -d Mbps | sort -n > /tmp/upload.txt
#cat "$(ls -rt /tmp/speedtestResult/*.log | tail -n1)" | grep -i upload | tr -d "Avg: " | tr -d Mbps | sort -n > /tmp/upload.txt
#ls -drt /tmp/* 2>/dev/null | tail -n1













#ls -drt /tmp/* 2>/dev/null | tail -n1









#dd if=/dev/zero of=/dev/sd bs=4096 status=progress #direct








#echo "rtrMODEL: $rtrMODEL" #strings $SYSUPF | tail -n3 #if ! strings $SYSUPF | tail -n3 | grep -q "$rtrMODEL"; then
#echo "strings $SYSUPF | tail -n3 | grep 'metadata'"; strings $SYSUPF | tail -n3 | grep 'metadata'; #exit 0


#| sed 's|.*supported_devices||g' | cut -d'[' -f2 | cut -d']' -f1
#echo "{  "metadata_version": "1.1", "compat_version": "1.0",   "supported_devices":["raspberrypi,4-model-b"], "version": { "dist": "OpenWrt", "version": "SNAPSHOT", "revision": "r14176-bda1c127cc", "target": "bcm27xx/bcm2711", "board": "rpi-4"  }  }" | sed 's|.*supported_devices||g' | cut -d'[' -f2 | cut -d']' -f1

#echo "{  "metadata_version": "1.1", "compat_version": "1.0",   "supported_devices":["raspberrypi,4-model-b"], "version": { "dist": "OpenWrt", "version": "SNAPSHOT", "revision": "r14176-bda1c127cc", "target": "bcm27xx/bcm2711", "board": "rpi-4"  }  }" | sed 's|.*board.[[:space:]]||g' | cut -d' ' -f1

#jq -rR #...





####ISSUES echo "if ! echo ${IMAGEMETAstr} | grep -q \"$rtrMODEL\"; then"
#IMGMETAstr=$(strings $SYSUPF | tail -n3 | grep 'metadata')
#IMGMETAboardf=$(echo "${IMAGEMETAstr}" | sed 's|.*supported_devices||g' | cut -d'[' -f2 | cut -d']' -f1)
############echo "################DBG"
    if ! echo $IMAGEMETAstr | grep -q "$rtrMODEL"; then
        echo "IMAGE: $(basename $SYSUPF) incompatible:$rtrMODEL"

        echo "dbg $IMAGEMETAstr"


        exit 0
    else
        echo "IMAGE: $(basename $SYSUPF) compatible:$rtrMODEL"
    fi
    sleep 5





#####echo "rtrMODEL: $rtrMODEL" #strings $SYSUPF | tail -n3 #if ! strings $SYSUPF | tail -n3 | grep -q "$rtrMODEL"; then
##echo "strings $SYSUPF | tail -n3 | grep 'metadata'"; strings $SYSUPF | tail -n3 | grep 'metadata'; #exit 0
##echo "if ! echo ${IMAGEMETAstr} | grep -q \"$rtrMODEL\"; then"
########echo "################DBG"


    #echo "CHEESE0"; cat /tmp/imgmetastr
    #echo "CHEESE1"; cat /tmp/imgmetastr | sed 's|.*supported_devices||g'
    #echo "CHEESE2"; cat /tmp/imgmetastr | sed 's|.*supported_devices||g' | cut -d'[' -f2 | cut -d']' -f1
    #echo "CHEESE6"; cat /tmp/imgmetastr | sed 's|.*supported_devices||g' | cut -d'[' -f2 | cut -d']' -f1 | cut -d'"' -f2




list=$(echo "$data" | jq -r '.[] | .name, .id')
printf "$list"






#ubus -S call system board | jsonfilter -e '@.release.description'










#diff /path/to/local/file  < ( ssh user@remotehost 'cat /path/to/remote/file' )











#!/usr/bin/env bash
# thisfile: remove_dups_tmbackup.sh

# save the current path
CURRENT_DIR=$(pwd)

# receive backup destinarion directory as argument
DEST_DIR="$1"

# search for last previous destination directory name
PREVIOUS_DEST=`find "$DEST_DIR" -maxdepth 1 -type d -name "????-??-??-??????" -prune | sort -r | head -n 2 | tail -n 1`
# search for last destination directory name
LAST_DEST=`find "$DEST_DIR" -maxdepth 1 -type d -name "????-??-??-??????" -prune | sort -r | head -n 1`
# if is the same, exit (to avoid comparing to itself!!!)
eval "if [ \"$PREVIOUS_DEST\" == \"$LAST_DEST\" ]; then echo \"There is only one backup\" ; exit 1 ;fi";
# get only the dirname from path.
LAST_DEST_DIRNAME=`echo "$LAST_DEST" | rev | cut -d '/' -f 1 | rev`

# enter into previous destination directory
cd "$PREVIOUS_DEST" || { echo \"Failed to get in correct directory\" ; exit 1 ; }
# search previus backup files and compare with new at same path
# if both point to same inode then we delete previous backup one
find . -type f -print0 | while read -d '' -r file; do
   #echo "if [ `printf '%q' \"$file\"` -ef `printf '../%q/%q' \"$LAST_DEST_DIRNAME\" \"$file\"` ]; then rm -vf `printf '%q' \"$file\"` ;fi";
    eval "if [ `printf '%q' \"$file\"` -ef `printf '../%q/%q' \"$LAST_DEST_DIRNAME\" \"$file\"` ]; then rm -f `printf '%q' \"$file\"` ;fi";
done
# delete also empty directories left
find . -type d -empty -delete
# go back to previous directory
cd "$CURRENT_DIR"










