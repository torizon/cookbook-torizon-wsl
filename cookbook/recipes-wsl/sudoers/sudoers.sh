#!/bin/bash

IMAGE_MNT_ROOT="$BUILD_PATH/tmp/$MACHINE/mnt/root"

# remove the Default PATH from the sudoers file
echo $USER_PASSWD | sudo -E -S  \
sed -i '/^Defaults\ssecure_path=/s/^/#/' ${IMAGE_MNT_ROOT}/etc/sudoers
