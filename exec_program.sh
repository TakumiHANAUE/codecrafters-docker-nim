#!/bin/bash

CMDNAME=`basename $0`

if [ $# -eq 0 ]; then
  echo "Usage : $CMDNAME IMAGE COMMAND [ARGS]"
  echo "  IMAGE : ex) alpine:latest"
  echo "  COMMAND : ex) /bin/echo"
  echo "  COMMAND : ex) hey"
  exit 1
fi

docker build -t mydocker . && docker run --name mydocker_cont --cap-add="SYS_ADMIN" mydocker run $@
echo "[Exit code] $?"
echo "[Logs]"
docker logs mydocker_cont
echo ""
echo -n "Remove container : "
docker rm mydocker_cont
