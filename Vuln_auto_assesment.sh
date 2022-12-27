#!/usr/bin/env bash

# check for dependencies
if ! command -v nmap > /dev/null; then
  echo "Nmap is not installed. Installing..."
  sudo apt update
  sudo apt install nmap
fi

if ! command -v openvas > /dev/null; then
  echo "OpenVAS is not installed. Installing..."
  sudo apt update
  sudo apt install openvas
fi

# scan target system with nmap
echo "Scanning target system with Nmap..."
nmap -sV -sC -p- -oA nmap_scan example.com

# scan target system with openvas
echo "Scanning target system with OpenVAS..."
openvas-setup
openvas-start
openvas-client -u $1 -w $2 -iX > openvas_scan.xml
