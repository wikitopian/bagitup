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
RemoteBackupDir[0]="bagitup"
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

    ssh ${Host[$i]} "mkdir -p ${RemoteBackupDir[$i]}"
    ssh ${Host[$i]} "mysqldump --host=${SqlHost[$i]} --user=${SqlUser[$i]} --password=${SqlPass[$i]} --all-databases > ${RemoteBackupDir[$i]}/${Host[$i]}-data-backup.sql"

    sshfs -C -o reconnect ${Host[$i]}: ${MountDir[$i]}

    rsync -aPvz ${MountDir[$i]}/${RemoteBackupDir[$i]}/ ${LocalDir[$i]}/${Host[$i]}/local/data
    rsync -aPvz ${MountDir[$i]}/${RemoteDir[$i]}/       ${LocalDir[$i]}/${Host[$i]}/local/file
    
    fusermount -u ${MountDir[$i]}

    find ${LocalDir[$i]}/${Host[$i]}/local/file -type f -print0 \
	    | xargs -0 du -s \
	    | sed 's/^\([^\s]\+\)\s\+\(.*\)/\2\t\1/' \
	    | sort \
	    | sed 's/^\([^\t]\)\t\(.*\)/\2\t\1/' \
	    > ${Repo}/${Host[$i]}.txt

    git --work-tree=${Repo} --git-dir=${Repo}/.git add    ${Repo}/${Host[$i]}.txt
    git --work-tree=${Repo} --git-dir=${Repo}/.git commit -m "Modified: ${Host[$i]}"

done
