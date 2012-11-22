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
LocalDir="./backup-archive"
RemoteDir="~/backup"
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
            echo "Connecting: ${SqlHost[$i]}::${SqlUser[$i]}::${RemoteDir[$i]} --> ${LocalDir[$i]}"
            ssh ${Host[$i]} "mkdir -p ${RemoteDir[$i]}"
            # Remove/Create tar ball of filesystem
            ssh ${Host[$i]} "rm -f ${RemoteDir[$i]}/${Host[$i]}-db.sql"
            ssh ${Host[$i]} "mysqldump --host=${SqlHost[$i]} --user=${SqlUser[$i]} --password=${SqlPass[$i]} --all-databases > ${RemoteDir[$i]}/${Host[$i]}-db.sql"
            # Gzip two files with --rsyncable
            mkdir -p ${LocalDir[$i]}/{$Host[$i]}
            rsync -avz --delete --progress -e ssh ${Host[$i]}:~/backup ${LocalDir[$i]}/${Host[$i]}

            ;;
        "sshfs")
            ;;
        *)
            echo "Invalid host type"
            ;;
    esac
done
