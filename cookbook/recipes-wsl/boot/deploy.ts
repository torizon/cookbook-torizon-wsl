#!/opt/bun/bin/bun

import PATH from "path"
import FS from "fs"
import logger from "node-color-log"
import { execSync } from "child_process"

const ARCH = process.env.ARCH as string
const MACHINE = process.env.MACHINE as string
const MAX_IMG_SIZE = process.env.MAX_IMG_SIZE as string
const BUILD_PATH = process.env.BUILD_PATH as string
const DISTRO_MAJOR = process.env.DISTRO_MAJOR as string
const DISTRO_MINOR = process.env.DISTRO_MINOR as string
const DISTRO_PATCH = process.env.DISTRO_PATCH as string
const USER_PASSWD = process.env.USER_PASSWD as string

// get the actual script path, not the process.cwd
const _path = PATH.dirname(process.argv[1])
const meta = JSON.parse(process.env.META as string)

logger.info(`deploy ${meta.name} ...`)

const IMAGE_MNT_BOOT = `${BUILD_PATH}/tmp/${MACHINE}/mnt/boot`
const IMAGE_MNT_ROOT = `${BUILD_PATH}/tmp/${MACHINE}/mnt/root`
process.env.IMAGE_MNT_BOOT = IMAGE_MNT_BOOT
process.env.IMAGE_MNT_ROOT = IMAGE_MNT_ROOT

// copy the boot script to the rootfs
execSync(
    `echo ${USER_PASSWD} | sudo -k -S ` +
    `cp ${_path}/boot.xsh ${IMAGE_MNT_ROOT}/bin/`,
    {
        shell: "/bin/bash",
        stdio: "inherit",
        encoding: "utf-8",
        env: process.env
    })

execSync(
    `echo ${USER_PASSWD} | sudo -k -S ` +
    `cp ${_path}/specific_init.sh ${IMAGE_MNT_ROOT}/opt/specific_init.sh`,
    {
        shell: "/bin/bash",
        stdio: "inherit",
        encoding: "utf-8",
        env: process.env
    })

execSync(
    `echo ${USER_PASSWD} | sudo -k -S ` +
    `cp ${_path}/user_init.xsh ${IMAGE_MNT_ROOT}/opt/user_init.xsh`,
    {
        shell: "/bin/bash",
        stdio: "inherit",
        encoding: "utf-8",
        env: process.env
    })

// give the boot script execution permission
execSync(
    `echo ${USER_PASSWD} | sudo -k -S ` +
    `chmod +x ${IMAGE_MNT_ROOT}/bin/boot.xsh`,
    {
        shell: "/bin/bash",
        stdio: "inherit",
        encoding: "utf-8",
        env: process.env
    })

execSync(
    `echo ${USER_PASSWD} | sudo -k -S ` +
    `chmod +x ${IMAGE_MNT_ROOT}/opt/specific_init.sh`,
    {
        shell: "/bin/bash",
        stdio: "inherit",
        encoding: "utf-8",
        env: process.env
    })

execSync(
    `echo ${USER_PASSWD} | sudo -k -S ` +
    `chmod +x ${IMAGE_MNT_ROOT}/opt/user_init.xsh`,
    {
        shell: "/bin/bash",
        stdio: "inherit",
        encoding: "utf-8",
        env: process.env
    })

logger.success(`Deployed ${meta.name}!`)
