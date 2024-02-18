#!/opt/bun/bin/bun

import * as FS from "fs"
import PATH from "path"

import { execSync } from "child_process"
import logger from "node-color-log"

// gaia need to previously set arhitecture and machine
const ARCH = process.env.ARCH as string
const MACHINE = process.env.MACHINE as string
const BUILD_PATH = process.env.BUILD_PATH as string

// get the actual script path, not the process.cwd
const _path = PATH.dirname(process.argv[1])

// set the working directory
process.chdir(`${BUILD_PATH}/tmp/${MACHINE}/neofetch`)

// patch
logger.info(`patching neofetch ...`)
execSync(
    `git apply ${_path}/git/*.patch`,
    {
        shell: "/bin/bash",
        stdio: "inherit",
        encoding: "utf-8"
    }
)
logger.success(`ok, neofetch patched`)
