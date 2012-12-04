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

# Set global defaults
LocalDir[0]="./backup-archive"
RemoteDir[0]="~"
RemoteBackupDir[0]="~/backup"
Type[0]="rsync"
Output[0]="/dev/stdout"
SqlHost[0]="localhost"

# Read the config file
source $CONFIG_FILE

for i in "${!Host[@]}"
do
    echo "Backing up ${Host[$i]}..."

    if [[ -z "${LocalDir[$i]}" ]]
    then
        LocalDir[$i]="${LocalDir[0]}"
    fi

    if [[ -z "${RemoteDir[$i]}" ]]
    then
        RemoteDir[$i]="${RemoteDir[0]}"
    fi

    if [[ -z "${RemoteBackupDir[$i]}" ]]
    then
        RemoteBackupDir[$i]="${RemoteBackupDir[0]}"
    fi

    if [[ -z "${Type[$i]}" ]]
    then
        Type[$i]="${Type[0]}"
    fi

    if [[ -z "${Output[$i]}" ]]
    then
        Output[$i]="${Output[0]}"
    fi

    if [[ -z "${SqlHost[$i]}" ]]
    then
        SqlHost[$i]="${SqlHost[0]}"
    fi

    case ${Type[$i]} in
        "rsync")
            source "includes/backup-rsync.sh"
            ;;
        "sshfs")
            ;;
        *)
            echo "Invalid host type"
            ;;
    esac
done
