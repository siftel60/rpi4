#!/bin/sh


#/etc/opkg/keys /lib/upgrade/keep.d/opkg:/etc/opkg/keys/











#rsync -ax (or cp -ax on individual toplevel directories)
rsyncexclude() {
cat <<'LLL'
/dev
/lost+found
/mnt
/proc
/run
/sys
/tmp
#####################
/rom
/overlay
#####################
/var
/lib64
#####################
/restorefiles
LLL
#exclude mounts automatic @ /usbstick
#so boot needs to come after
}




rsyncEM() {

FAKEd="/tmp/rsyncFAKE"

rm -rf ${FAKEd:-randomwrongpath}/
mkdir -p $FAKEd

rsyncexclude > /tmp/syncX


echo "rsync --exclude-from=/tmp/syncX -ax / $FAKEd/"
rsync --exclude-from=/tmp/syncX -ax / $FAKEd/
rsync -ax /boot/ $FAKEd/boot/


rm /tmp/syncX 2>/dev/null

echo "SWIRL"; exit 0

}



















dumprmfiles() {


case "${1}" in
	restoresensitive)
cat <<'FFF'
etc/passwd
etc/shadow
etc/group
etc/config/rpcd
etc/config/uhttpd
etc/opkg*
etc/shinit
etc/shells
FFF
	;;

	combulk)
cat <<'FFF'
restorefiles/installed_packages.txt-*
restorefiles/systeminfo.*
restorefiles/config-firstboot-post-*
restorefiles/config-firstboot-pre-*
etc/custom/firewall*
restorefiles/oinstlog-*
restorefiles/uci.*
FFF
	;;

	rmcommunity)
cat <<'FFF'
etc/firewall.user
etc/rc.local
etc/profile.d/zshddir.sh
etc/profile.d/ashprofile.sh
etc/profile.d/99-updatecheck.sh
etc/profile.d/97-sysinfo.sh
etc/profile.d/55-lucisshon.sh
FFF
	;;
esac


}


#etc/config/servicestate*



dumpessentialfiles() {

cat <<'LLL'
etc/uhttpd.key
etc/uhttpd.crt
etc/backup/installed_packages.txt
LLL

}




fails() {
    echo "$1" && exit 1
}
usage() {
cat <<EOG

    $0 repack -F <file.tar.gz> [configonly]
    $0 repack [configonly]
    $0 raw			dump large tar.gz not suitable for direct restore


	replace			replace-infile
	configonly		[most things except stats-keys-boot-ifpresent] #minimal comfiles saferestore?

	nokeys			[uhttpd+dropbear keys]
	nonetwork		[/etc/config/network:/etc/config/wireless]
	nosystem		[/etc/config/system]
	noboot			[/boot/*]
	nostats			[/tmp/*:/var/* WARNINGLOOSELOGIC]

	norm			[leave repack tmpdirs in place]
	alttar			[retain removed files in seperate tar.gz]


	incdir|-I <dir>		[TBA merge sep-dir i.e. '/tmp/merge'/etc/uci-defaults/abc]

EOG

}









#@@@ support -O OUTFILE #complex-only-on-infileORnoreplace etc. etc. or just mv right at the end
#@@@ keep replackd?





if [ "$#" -eq 0 ]; then usage && exit 0; fi
while [ "$#" -gt 0 ]; do
case "${1}" in
    help|-h|--help) usage; exit 0; ;;
    "-v") VERBOSE="-v"; shift 1; ;;
    norm) NORM=1; shift 1; ;;
    -F) SYSUPIN="${2}"; shift 2; ;;
    repack) REPACKTARGZ=1; shift 1; ;;
    force) FORCE="force"; shift 1; ;;
    replace) REPLACEINFILE=1; shift 1; ;;
    alttar) ALTTAR=1; shift 1; ;;
    raw) RAWDUMP=1; shift 1; ;;
    minimal|combulk|configonly|saferestore) REPACKOPTS="$REPACKOPTS $1"; shift 1; ;;
    nokeys|nonetwork|noboot|nosystem) REPACKOPTS="$REPACKOPTS $1"; shift 1; ;;
    nostats) REPACKOPTS="$REPACKOPTS $1"; shift 1; ;;
    *) echo "unknown-parameter: $1"; usage; shift 1; sleep 1; exit 0; ;;
esac
done






eCHo() {
	if [ ! -z "$VERBOSE" ]; then
		echo "${1}"
	fi
}




rmbackupfiles() {


	eCHo "${1} #${2}"; sleep ${RCSLEEP:-0}

	if [ ! -z "$REPACKdRM" ]; then
		#echo "DBG cp -arf \"${1}\" ${REPACKdRM} 2>/dev/null"; sleep 1; cp -arf "${1}" ${REPACKdRM} 2>/dev/null
		cd $REPACKd && tar -czf - "${1}" 2>/dev/null | (cd $REPACKdRM && tar -xzf - 2>/dev/null)

	fi
	


	#rm -rf "${1}" 2>/dev/null #orig did not handle 'etc/opkg*'	
	######################echo "rm -rf \"${1}\""; rm -rf "${1}"; sleep 1
	#########################pwd; find . | grep "${1}"; sleep 2

	if [ "$(pwd)" = "/" ]; then echo "oops /"; return 1; fi
	#@@@create summary file
	rm -rf $(find . | grep "./${1}")

	if [ "$(find . | grep "./${1}" | wc -l)" -gt 0 ]; then
		echo "############ post-rm-check ./${1} fail"
		find . | grep "${1}"; sleep 2
	fi
	sleep ${RCSLEEP:-0}
}

#/tmp/repackalt/shells
#/tmp/repackalt/shinit








rawdump() {



DD=$(date +%Y%m%d%H%M)
OUTd="/tmp/upgbackup-${DD}" #OUTd="./upgbackup-${DD}"

eval $(grep '^BACKUPdirL=' /root/wrt.ini 2>/dev/null)

mkdir -p $OUTd

( /bin/opK ) &
echo "####### dump full backup ( not for typical restore !!! )"; sleep 1

######################################
sysupgrade -b $OUTd/backup.tar.gz 2>/dev/null
######################################

################################## ####cp /restorefiles/opkg.restore.added $OUTd/
cp /restorefiles/uci.history $OUTd/
cp /restorefiles/uci.sincenew $OUTd/
###############
cp /restorefiles/opkg.restore.* $OUTd/
########################################
echo "copy full /etc"
cp -rf /etc/ $OUTd/
echo "copy full /root"
cp -rf /root $OUTd/
######################################
echo "copy full /restorefiles"
cp -rf /restorefiles $OUTd/
echo "copy full /boot"
cp -rf /boot $OUTd/
########################################
echo "copy wrt.ini"
cp /root/wrt.ini $OUTd/
########################################
echo "copy /tmp/rrd"
cp -rf /tmp/rrd $OUTd/tmp_rrd
echo "copy /var/lib/nlbwmon"
cp -rf /var/lib/nlbwmon/ $OUTd/var_lib_nlbwmon

getsize() {
du -chs $1 | head -n1 | tr -s '\t' ' ' | cut -d' ' -f1
} #echo "dumped manual backup: $OUTd $(du -chs $OUTd | head -n1 | tr -s '\t' ' ' | cut -d' ' -f1)"
echo "dumped manual backup: $OUTd $(getsize $OUTd)"


USERbTAR="/tmp/userbackup-$DD.tar.gz"
rLANIP=$(ip addr | grep br-lan | grep inet | tr -s '\t' ' ' | cut -d' ' -f3 | cut -d'/' -f1)


(cd $OUTd
tar -czf $USERbTAR .
)

#rm /www/userbackup.tar.gz 2>/dev/null
ln -s $USERbTAR /www/userbackup.tar.gz

echo "Compressing into: $USERbTAR ( http://$rLANIP/userbackup.tar.gz ) $(getsize $USERbTAR)"

if [ ! -z "$BACKUPdirL" ]; then
	if [ -d "$BACKUPdirL" ]; then
		echo "local-backup-keep@BACKUPdirL: $BACKUPdirL [copy]"
		cp $USERbTAR $BACKUPdirL/
		echo "total-BACKUPdirL space used: $(getsize $BACKUPdirL)"
	else
		echo "local-backup-keep@BACKUPdirL: $BACKUPdirL [dirnotvalid]"
	fi
else
	echo "wrt.ini BACKUPdirL=\"/somepath\" to keep on router USB!"
fi



rm -rf $OUTd



USERbTARnT="$(find /tmp/userbackup-*.tar.gz | wc -l)"
echo "tmp-userbackups: $USERbTARnT"

if [ ! -z "$BACKUPdirL" ]; then
	if [ -d "$BACKUPdirL" ]; then
		USERbTARnD="$(find ${BACKUPdirL}/*.tar.gz | wc -l)"
		echo "dir-userbackups: $USERbTARnD"
	fi
fi


}










repacktargz() {


	if [ -d "$REPACKd" ]; then fails "repackD no cleanedup: $REPACKd"; fi
	mkdir -p $REPACKd
	
	SYSUPOUT="/tmp/$(echo $(basename $SYSUPIN) | sed 's!\.tar\.gz!!g').repack.tar.gz"

	echo "Creating repack@: $SYSUPOUT"; sleep 3
	#echo "SLIVE"; exit 0


	cp -a $SYSUPIN $REPACKd

	cdir=$(pwd)
	cd $REPACKd || fails "cd to REPACKd failed: $REPACKd"

	tar -xzf $(basename $SYSUPIN) #tar -xvzf $(basename $SYSUPIN)
	rm $(basename $SYSUPIN)




	############################################################
	#MEHJUSTUSELIVE cp -rf $REPACKd $REPACKdO #for uci diffs etc
	############################################################




find . > /tmp/.repack.pre
du -chs $REPACKd | head -n1 > /tmp/.repack.presz


#@@@mv ./norestore insteadof rm -rf all || create backupextras.tar.gz???

case "$REPACKOPTS" in
	*"knownbugs"*|*"saferestore"*|*"configonly"*)
while read rmPATH; do
	#echo "Removing restoresensitive: $rmPATH" #echo "rm -rf $rmPATH"
	#rm -rf $rmPATH 2>/dev/null


	#set -x
	#echo "rmbackupfiles \"$rmPATH\" restoresensitive"; sleep 2
	rmbackupfiles "$rmPATH" restoresensitive
	#set +x

	sleep ${RCSLEEP:-0}



	done <<VVV
$(dumprmfiles restoresensitive)
VVV
	;;
esac; rmPATH=








case "$REPACKOPTS" in
	*"combulk"*|*"minimal"*|*"configonly"*)
while read rmPATH; do
	
	#echo "Removing commbulk: $rmPATH"; rm -rf $rmPATH 2>/dev/null ###echo "rm -rf $rmPATH"
	rmbackupfiles "$rmPATH" commbulk
	
	sleep ${RCSLEEP:-0}
	done <<VVV
$(dumprmfiles combulk)
VVV
	;;
esac; rmPATH=





case "$REPACKOPTS" in
	*"combulk"*|*"minimal"*|*"configonly"*)
while read rmPATH; do
	
	#echo "Removing communityonly: $rmPATH"; rm -rf $rmPATH 2>/dev/null
	rmbackupfiles "$rmPATH" communityonly
	
	sleep ${RCSLEEP:-0}
	done <<VVV
$(dumprmfiles rmcommunity)
VVV
	;;
esac; rmPATH=






case "$REPACKOPTS" in
	*"configonly"*)
	
	#eCHo "Removing restorefiles/" #echo "rm -rf restorefiles"
	#rm -rf restorefiles/ 2>/dev/null
	rmbackupfiles "restorefiles/" restorefiles

	rm etc/config/.servicestate 2>/dev/null
	rm etc/config/servicestate-* 2>/dev/null
	rm etc/config/opkg-* 2>/dev/null
	rm etc/config/opkg_* 2>/dev/null

	sleep ${RCSLEEP:-0}
	;;
esac






case "$REPACKOPTS" in
	*"nokeys"*) #eCHo "Removing keys"
	rmbackupfiles "etc/dropbear*" keys
	rmbackupfiles "etc/uhttpd.crt" keys
	rmbackupfiles "etc/uhttpd.key" keys
	sleep ${RCSLEEP:-0}
	;;
esac #rm -rf etc/dropbear* 2>/dev/null; rm -rf etc/uhttpd.crt 2>/dev/null; rm -rf etc/uhttpd.key 2>/dev/null






case "$REPACKOPTS" in #@@@ -z noswitchvlan
	*"nonetwork"*) #eCHo "Removing network"
	rmbackupfiles "etc/config/network" nonetwork
	rmbackupfiles "etc/config/wireless" nonetwork
	sleep ${RCSLEEP:-0}
	;;
esac



case "$REPACKOPTS" in
	*"nosystem"*) #eCHo "Removing boot"
	rmbackupfiles "etc/config/system" nosystem
	;;
esac




case "$REPACKOPTS" in
	*"noboot"*) #eCHo "Removing boot"
	rmbackupfiles "boot/" noboot
	sleep ${RCSLEEP:-0}
	;;
esac





case "$REPACKOPTS" in
	*"nostats"*) #eCHo "Removing boot"
	rmbackupfiles "tmp/" nostats
	rmbackupfiles "var/" nostats
	sleep ${RCSLEEP:-0}
	;;
esac










#@@@MODIFY-PARTFILES-HERE





find . > /tmp/.repack.post
du -chs $REPACKd | head -n1 > /tmp/.repack.postsz



if [ ! -z "$VERBOSE" ]; then
	#@@@numfiles pre post
	#diff /tmp/.repack.pre /tmp/.repack.post #find $REPACKd #DEBUGONLY
	cat /tmp/.repack.presz
	cat /tmp/.repack.postsz
fi



tar -czf $SYSUPOUT .
cd $cdir




if [ -d "$REPACKdRM" ]; then
	SYSUPOUTALT="/tmp/$(echo $(basename $SYSUPIN) | sed 's!\.tar\.gz!!g')-alt.repack.tar.gz"
	echo "Packing alt.tar.gz: $SYSUPOUTALT"; sleep 2
	cd $REPACKdRM
	tar -czf $SYSUPOUTALT .
	cd $cdir
fi




if [ -z "$NORM" ]; then
	rm -rf $REPACKd
else
	echo "Leaving tmpdir: $REPACKd"
fi



} ####################################################################
######################################################################



UCI() {

	:
}

#uci -c /tmp/repack/etc/config show dhcp #############uci -P /tmp/repack/etc/config/ show









if [ ! -z "$RAWDUMP" ]; then
	rawdump
	exit 0
fi








REPACKd="/tmp/repack" #REPACKd="/tmp/repack"
REPACKdO="/tmp/repack-original" #UNUSED
#DEBUG
#rm -rf $REPACKd 2>/dev/null







if [ ! -z "$REPACKTARGZ" ]; then


	#if [ -z "$SYSUPIN" ] || [ ! -f "$SYSUPIN" ]; then usage; fails "infile incorrect: $SYSUPIN"; fi
	if [ ! -z "$SYSUPIN" ] && [ ! -f "$SYSUPIN" ]; then
		fails "infile incorrect: $SYSUPIN" 
	elif [ -z "$SYSUPIN" ]; then
		SYSUPIN=/tmp/backup.tar.gz
		sysupgrade -k -b $SYSUPIN 2>/dev/null 1>/dev/null
		#@@@ REPLACEINFILE=1
	fi


	echo "Repacking: $SYSUPIN opts:$REPACKOPTS replace:${REPLACEINFILE:-off}"; sleep 2


	if [ -z "$REPACKOPTS" ]; then
		echo "No repack opts... result will equal source" && sleep 2
	fi


	if [ ! -z "$ALTTAR" ]; then
		REPACKdRM="/tmp/repackalt"; mkdir -p $REPACKdRM	
		echo "Keeping alttar: $REPACKdRM"; sleep 2
	fi



	repacktargz #@@@ REPACKOPTS SYSUPIN REPACKd


	if [ ! -z "$REPLACEINFILE" ]; then
		echo "Replace INFILE $SYSUPOUT -> $SYSUPIN"; sleep 2
		mv $SYSUPOUT $SYSUPIN
	else
		echo "ReplaceNo OUTFILE:$SYSUPOUT INFILE:$SYSUPIN"; sleep 2
	fi
	#@@@elif -f /tmp/backup.tar.gz


fi








exit 0


#@raw /tmp/userbackup*

echo "########### cleanup"
ls -1 /tmp | grep upgbac


exit 0





























#rsync -ax (or cp -ax on individual toplevel directories)
Brsyncexclude() {
cat <<'LLL'
/dev
/lost+found
/mnt
/proc
/run
/sys
/tmp
#####################
/rom
/overlay
#####################
/var
/lib64
#####################
/restorefiles
LLL
#exclude mounts automatic @ /usbstick
#so boot needs to come after
}



FAKEd="/tmp/rsyncFAKE"

rm -rf ${FAKEd:-randomwrongpath}/
mkdir -p $FAKEd

rsyncexclude > /tmp/syncX


echo "rsync --exclude-from=/tmp/syncX -ax / $FAKEd/"
rsync --exclude-from=/tmp/syncX -ax / $FAKEd/
rsync -ax /boot/ $FAKEd/boot/





echo "SWIRL"; exit 0



















#rsync -ax (or cp -ax on individual toplevel directories)
Arsyncexclude() {
cat <<'LLL'
/dev
/lost+found
/mnt
/proc
/run
/sys
/tmp
LLL
}

#rsync -ax
#--exclude=PATTERN        exclude files matching PATTERN #--exclude-from=FILE      read exclude patterns from FILE
#--include=PATTERN        don't exclude files matching PATTERN #--include-from=FILE      read include patterns from FILE
#--files-from=FILE        read list of source-file names from FILE



################################################################
#Shut down all nonessential programs (basically, everything except the root shell you're working in -- don't try this from an X terminal, use a real console shell). Single-user mode may help for this.
#If you've got mounted disks other than the system root, unmount them. Don't unmount virtual filesystems such as /proc, /sys, or /dev.
#Flush cached data on the remaining disk: sync
#Remount the root filesystem read-only: mount -o ro /
#################################################################


















######## for 'files' aka pre-configured community
#1 add wrt.ini heredoc and add variable for services enabled
#2 add fake packagesinstall.txt
#3 user uses a) sysup -f custbackup.tar.gz community.img.gz or b) unpack in mounted sdcard?



























#cat /lib/upgrade/keep.d/* | sort | uniq | sed 's!^/!!g' > /tmp/$(basename $0).keepdonly
#sysupgrade -l 2>/dev/nulll | sort | uniq | sed 's!^/!!g' > /tmp/$(basename $0).fulllist
#echo "SUNNY"; exit 0




#cat /lib/upgrade/keep.d/* | sort | uniq
#cat /lib/upgrade/keep.d/* | sort | uniq | sed 's!^/!!g'










#WIP backup cleaner... ( re-download in a few days or a week or will be in next build ) to test it;

#```
#curl -sSL "https://raw.github.com/wulfy23/rpi4/master/utilities/sysupgrade-clean-backup.sh" > /bin/sysupgrade-clean-backup.sh
#chmod +x /bin/sysupgrade-clean-backup.sh
######then basic usage for now NOTE: this 'configonly' is the maximum scrubbing option
#sysupgrade-clean-backup.sh repack -F TEST.tar.gz configonly replace
#```



