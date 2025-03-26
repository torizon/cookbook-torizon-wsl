#!/bin/bash

IMAGE_MNT_ROOT="$BUILD_PATH/tmp/$MACHINE/mnt/root"

# remove the Default PATH from the sudoers file
sudo -E  \
sed -i '/^Defaults\ssecure_path=/s/^/#/' ${IMAGE_MNT_ROOT}/etc/sudoers
