#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "$0") && pwd)

cd $SCRIPT_DIR/files
./launch_container.sh stop
