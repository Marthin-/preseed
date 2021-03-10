#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 vars_file"
    exit 1
else
    ## default values
    hostname=debian
    cpu=1
    memory=4096
    disk_size=32
    disk_format=qcow2
    net_bridge=br0
    location=http://ftp.debian.org/debian/dists/stable/main/installer-amd64/
    preseed_file=/tmp/preseed.cfg
    ip=192.168.1.42
    mask=255.255.255.0
    gw=192.168.1.1
    dns=8.8.8.8
    disk_name=/dev/vda
    proxy=""
    [ -f $1 ] || { echo "preseed_vars file does not exist!" ; exit 1; }
    source $1

    read -s -p "enter root pw > " root_pw
    echo

    sed "s/HOSTNAME/$hostname/" ./preseed.cfg.template > $preseed_file
    sed -i "s:IP:$ip:" $preseed_file
    sed -i "s:MASK:$mask:" $preseed_file
    sed -i "s:GW:$gw:" $preseed_file
    sed -i "s:DNS:$dns:" $preseed_file
    sed -i "s:ROOT_PW:$root_pw:" $preseed_file
    sed -i "s:DISK_NAME:$disk_name:" $preseed_file
    sed -i "s:PROXY:$proxy:" $preseed_file

    OPTIONS="--virt-type=kvm --name=$hostname --vcpus=$cpu --memory=$memory --os-variant=linux --disk size=$disk_size,format=$disk_format --network bridge=$net_bridge --console pty,target_type=serial --noautoconsole --location=$location --initrd-inject=$preseed_file -x 'auto=false,text,console=ttyS0,115200n8,serial'"

    virt-install $OPTIONS --noreboot
    rm $preseed_file
fi
