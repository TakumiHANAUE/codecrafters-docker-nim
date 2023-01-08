# Usage: your_docker.sh run <image> <command> <arg1> <arg2> ...

from os import commandLineParams
from osproc import execCmd
from strutils import join


# args[0] : command
# args[1..] : command's Nth arg
let args = commandLineParams()[2..^1]

# Standard input, output, error streams are inherited from the calling process.
discard execCmd(args.join(" "))
