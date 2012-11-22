#!/bin/bash

CONFIG_FILE=$HOME/.backuprc

# Find the config file

while getopts ":f" opt; do
    case $opt in
        f)
            echo "Custom config file: $2" >&2
            CONFIG_FILE=$2
            ;;
        \?)
            echo "USAGE: backup.sh [-f CONFIG_FILE]" >&2
            ;;
    esac
done

# Read the config file

source $CONFIG_FILE

for i in "${!Host[@]}"
do
    echo "Backing up ${Host[$i]}..."

    source "./includes/backup-rsync.sh"
done
