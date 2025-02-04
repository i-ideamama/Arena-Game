#!/bin/bash

# Check if a port number is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <port_number>"
    exit 1
fi

PORT=$1

# Check if the port is in use using netstat
netstat -anp | grep -q ":$PORT "

if [ $? -eq 0 ]; then
    # Port is in use
    echo 1
else
    # Port is not in use
    echo 0
fi

