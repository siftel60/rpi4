#!/bin/sh
cd /
opkg list-installed | grep -q '^wget' || opkg update && opkg install wget
wget https://github.com/wulfy23/rpi4/raw/master/utilities/putty/putty.tar.gz
tar -xvzf putty.tar.gz


