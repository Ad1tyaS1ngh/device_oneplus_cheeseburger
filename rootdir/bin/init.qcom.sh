#! /vendor/bin/sh

#
# Make modem config folder and copy firmware config to that folder for RIL
#
if [ -f /data/vendor/modem_config/ver_info.txt ]; then
    prev_version_info=`cat /data/vendor/modem_config/ver_info.txt`
else
    prev_version_info=""
fi

cur_version_info=`cat /vendor/firmware_mnt/verinfo/ver_info.txt`
if [ ! -f /vendor/firmware_mnt/verinfo/ver_info.txt -o "$prev_version_info" != "$cur_version_info" ]; then
    # add W for group recursively before delete
    chmod g+w -R /data/vendor/modem_config/*
    rm -rf /data/vendor/modem_config/*
    # preserve the read only mode for all subdir and files
    cp --preserve=m -dr /vendor/firmware_mnt/image/modem_pr/mcfg/configs/* /data/vendor/modem_config
    cp --preserve=m -d /vendor/firmware_mnt/verinfo/ver_info.txt /data/vendor/modem_config/
    cp --preserve=m -d /vendor/firmware/mbn_ota/mbn_ota.txt /data/vendor/modem_config/
    # the group must be root, otherwise this script could not add "W" for group recursively
    chown -hR radio.root /data/vendor/modem_config/*
fi
chmod g-w /data/vendor/modem_config
setprop ro.vendor.ril.mbn_copy_completed 1
