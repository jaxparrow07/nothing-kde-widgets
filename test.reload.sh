#!/usr/bin/env bash


if [[ -d "packages/$1" ]];then
	plasmoidviewer -a "packages/$1"

else
	echo "[!] Widget '$1' not found"
fi
