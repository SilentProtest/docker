#!/bin/bash

echo "Performing Reset"
rm -rf /data/db/* /data/configdb/*

echo "Starting"
/entrypoint.sh mongod

