#!/bin/bash

CMDNAME=`basename $0`

if [ $# -eq 0 ]; then
  echo "Usage : $CMDNAME COMMAND [ARGS]"
  echo "  COMMAND, ARGS : see docker-explorer --help"
  exit 1
fi

docker build -t mydocker . && docker run --name mydocker_cont --cap-add="SYS_ADMIN" mydocker run ubuntu:latest /usr/local/bin/docker-explorer $@
echo "[Exit code] $?"
echo "[Logs]"
docker logs mydocker_cont
echo ""
echo -n "Remove container : "
docker rm mydocker_cont
