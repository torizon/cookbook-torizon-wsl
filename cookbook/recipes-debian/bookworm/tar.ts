#!/usr/bin/env -S deno run --allow-all

import PATH from "node:path"
import FS from "node:fs"
import logger from "node-color-log"
import { execSync } from "node:child_process"

// run update in the chroot
logger.info("let's create a tar from the chroot ...")

const ARCH = process.env.ARCH as string
const MACHINE = process.env.MACHINE as string
const MAX_IMG_SIZE = process.env.MAX_IMG_SIZE as string
const BUILD_PATH = process.env.BUILD_PATH as string
const DISTRO_MAJOR = process.env.DISTRO_MAJOR as string
const DISTRO_MINOR = process.env.DISTRO_MINOR as string
const DISTRO_PATCH = process.env.DISTRO_PATCH as string
const USER_PASSWD = process.env.USER_PASSWD as string
const IMAGE_NAME = process.env.IMAGE_NAME as string

// get the actual script path, not the process.cwd
const _path = PATH.dirname(process.argv[1])

const IMAGE_PATH =
    `${BUILD_PATH}/tmp/${MACHINE}/deploy/${IMAGE_NAME}`
process.env.IMAGE_PATH = IMAGE_PATH

const IMAGE_MNT_BOOT = `${BUILD_PATH}/tmp/${MACHINE}/mnt/boot`
const IMAGE_MNT_ROOT = `${BUILD_PATH}/tmp/${MACHINE}/mnt/root`
process.env.IMAGE_MNT_BOOT = IMAGE_MNT_BOOT
process.env.IMAGE_MNT_ROOT = IMAGE_MNT_ROOT

// always clean the old .tar file
if (FS.existsSync(`${IMAGE_PATH}.tar`)) {
    execSync(
        `sudo -E rm -rf ${IMAGE_PATH}.tar`,
        {
            shell: "/bin/bash",
            stdio: "inherit",
            encoding: "utf-8",
            env: process.env
        })
    logger.debug("old tar file removed")
}

// first we need to clean the chroot bindigns
execSync(
    `sudo -E bash -c "` +
    `umount ${IMAGE_MNT_ROOT}/dev/pts && ` +
    `umount ${IMAGE_MNT_ROOT}/dev && ` +
    `umount ${IMAGE_MNT_ROOT}/proc && ` +
    `umount ${IMAGE_MNT_ROOT}/sys"`,
    {
        shell: "/bin/bash",
        stdio: "inherit",
        encoding: "utf-8",
        env: process.env
    })

// FIXME: this will remove with exit code, but should be ok
execSync(
    `sudo -E bash -c "` +
    `cd ${IMAGE_MNT_ROOT} && ` +
    `shopt -s dotglob; tar -cvpf ${IMAGE_PATH}.tar * || true"`,
    {
        shell: "/bin/bash",
        stdio: "inherit",
        encoding: "utf-8",
        env: process.env
    })
logger.success("ok, tar created from the image")
