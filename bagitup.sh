#!/bin/bash

CONFIG_FILE=$HOME/.bagituprc

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
LocalDir[0]="./bagitup-archive"
MountDir[0]="$HOME/mnt"
RemoteDir[0]="public_html"
RemoteBackupDir[0]="~/bagitup"
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

    if [[ -z "${MountDir[$i]}" ]]
    then
        MountDir[$i]="${MountDir[0]}/${Host[$i]}"
    fi

    if [[ -z "${RemoteDir[$i]}" ]]
    then
        RemoteDir[$i]="${RemoteDir[0]}"
    fi

    if [[ -z "${RemoteBackupDir[$i]}" ]]
    then
        RemoteBackupDir[$i]="${RemoteBackupDir[0]}"
    fi
    if [[ -z "${SqlHost[$i]}" ]]
    then
        SqlHost[$i]="${SqlHost[0]}"
    fi

    echo "Connecting: ${SqlHost[$i]}::${SqlUser[$i]}::${RemoteBackupDir[$i]} --> ${LocalDir[$i]}"

    mkdir -p ${MountDir[$i]}
    mkdir -p ${LocalDir[$i]}/${Host[$i]}/local/file
    mkdir -p ${LocalDir[$i]}/${Host[$i]}/local/data

    ssh ${Host[$i]} "mysqldump --host=${SqlHost[$i]} --user=${SqlUser[$i]} --password=${SqlPass[$i]} --all-databases > ${RemoteBackupDir[$i]}/${Host[$i]}-data-backup.sql"

    sshfs -C ${Host[$i]}: ${MountDir[$i]}
    sshfs -C ${Host[$i]}: ${MountDir[$i]}

    rsync -avz ${MountDir[$i]}/${RemoteDir[$i]} ${LocalDir[$i]}/${Host[$i]}/local/file
    rsync -avz ${MountDir[$i]}/${RemoteDir[$i]} ${LocalDir[$i]}/${Host[$i]}/local/data

    fusermount -u ${MountDir[$i]}

done