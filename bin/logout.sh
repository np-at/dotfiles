#!/usr/bin/env bash

# Path: logout.sh

# This script is sourced by .profile on logout

# dismount all veraCrypt volumes
if [[ -f /usr/bin/veracrypt ]]; then
	sudo veracrypt -d
fi
