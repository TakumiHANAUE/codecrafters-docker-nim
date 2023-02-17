# Usage: your_docker.sh run <image> <command> <arg1> <arg2> ...

import os
import osproc

proc chroot*(path: cstring): cint {.importc, header: "<unistd.h>".}
proc unshare*(flags: cint): cint {.importc, header: "<sched.h>".}
const CLONE_NEWPID = 0x20000000'i32

# args[0] : command
# args[1..] : command's Nth arg
let params = commandLineParams()[2..^1]
let command = params[0]
let commandArgs = params[1..^1]

# Create empty temp directory
let tmpDir = "./tmp_" & $getCurrentProcessId()
createDir(tmpDir)

# Copy the binary being executed to temp directory
let srcFile = params[0]
let dstFile = joinPath(tmpDir, srcFile)
## Create directory for executed binary
createDir(parentDir(dstFile))
## Copy executed binary
copyFileWithPermissions(srcFile, dstFile)

# Change current directory to temp directory
setCurrentDir(tmpDir)

# chroot to temp directory
discard chroot(cstring("."))

# unshare to create new pid namespace
discard unshare(CLONE_NEWPID)

# Execute Command in a child prosess
let p = startProcess(command, args=commandArgs, options={poParentStreams})
let errorCode = p.waitForExit()
close(p)

quit(errorCode)
