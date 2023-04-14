# Usage: your_docker.sh run <image> <command> <arg1> <arg2> ...

import os
import osproc
import dockerRegistoryClient

proc chroot*(path: cstring): cint {.importc, header: "<unistd.h>".}
proc unshare*(flags: cint): cint {.importc, header: "<sched.h>".}
const CLONE_NEWPID = 0x20000000'i32

# args[0] : command
# args[1..] : command's Nth arg
let params = commandLineParams()[1..^1]
let imageName = params[0]
let command = params[1]
let commandArgs = params[2..^1]

# Create empty temp directory
let tmpDir = "./tmp_" & $getCurrentProcessId()
createDir(tmpDir)

# Install image
if not pullImage(imageName, tmpDir):
    quit "Fail to pull image : " & imageName

# Copy the binary being executed to temp directory
let srcFile = command
let dstFile = joinPath(tmpDir, srcFile)
## Create directory for executed binary
if not existsDir(parentDir(dstFile)):
    createDir(parentDir(dstFile))
## Copy executed binary
if not existsFile(dstFile):
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
