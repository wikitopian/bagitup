#!/bin/bash

# Find and read the config

CONFIG_FILE=$HOME/.backuprc

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

echo $CONFIG_FILE
