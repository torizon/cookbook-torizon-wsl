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

const IMAGE_MNT_BOOT = `${BUILD_PATH}/tmp/${MACHINE}/mnt/boot`
const IMAGE_MNT_ROOT = `${BUILD_PATH}/tmp/${MACHINE}/mnt/root`
process.env.IMAGE_MNT_BOOT = IMAGE_MNT_BOOT
process.env.IMAGE_MNT_ROOT = IMAGE_MNT_ROOT

logger.info(`deploy ${meta.name} ...`)

// create the path only in case
execSync(
    `echo ${USER_PASSWD} | sudo -k -S ` +
    `mkdir -p ${IMAGE_MNT_ROOT}/opt/${meta.name}`,
    {
        shell: "/bin/bash",
        stdio: "inherit",
        encoding: "utf-8",
        env: process.env
    })

for (let _file of meta.files) {
    const _file_path = `${BUILD_PATH}/tmp/${MACHINE}/${meta.name}/${_file}`

    // copy the files to the rootfs
    execSync(
        `echo ${USER_PASSWD} | sudo -k -S ` +
        `cp ${_file_path} ${IMAGE_MNT_ROOT}/opt/${meta.name}/${_file}`,
        {
            shell: "/bin/bash",
            stdio: "inherit",
            encoding: "utf-8",
            env: process.env
        })
}

// copy the local file wslSocket
const _file_path = `${_path}/wslSocket`
execSync(
    `echo ${USER_PASSWD} | sudo -k -S ` +
    `cp ${_file_path} ${IMAGE_MNT_ROOT}/opt/${meta.name}/wslSocket`,
    {
        shell: "/bin/bash",
        stdio: "inherit",
        encoding: "utf-8",
        env: process.env
    })

// create a symlink to the /usr/bin
execSync(
    `echo ${USER_PASSWD} | sudo -k -S ` +
    `chroot ${IMAGE_MNT_ROOT} /bin/bash -c "` +
    `ln -sf /opt/${meta.name}/torizon-emulator-manager /usr/bin/emulator && ` +
    `ln -sf /opt/${meta.name}/torizon-emulator-manager /usr/bin/torizon-emulator-manager && ` +
    `chmod +x /usr/bin/torizon-emulator-manager && ` +
    `chmod +x /usr/bin/emulator && ` +
    `chmod +x /opt/${meta.name}/wslSocket` +
    `"`,
    {
        shell: "/bin/bash",
        stdio: "inherit",
        encoding: "utf-8",
        env: process.env
    })

logger.success(`Deployed ${meta.name}!`)
