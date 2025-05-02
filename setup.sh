#!/usr/bin/env bash
set -e

sudo apt update
sudo apt install -y dkms linux-headers-$(uname -r) build-essential

sudo dkms add -m imx586 -v 0.1 || true
sudo dkms build -m imx586 -v 0.1
sudo dkms install -m imx586 -v 0.1

echo "Driver built and installed. Merge the appropriate imx586-*.dtsi into your board DTS and rebuild the device tree."
