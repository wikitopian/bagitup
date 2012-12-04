echo "Connecting: ${SqlHost[$i]}::${SqlUser[$i]}::${RemoteBackupDir[$i]} --> ${LocalDir[$i]}"

touch ${Output}/${Host[$i]}-mkdir-remote.log
ssh ${Host[$i]} "mkdir -p ${RemoteBackupDir[$i]}" > ${Output}/${Host[$i]}-mkdir-remote.log
git --git-dir=${Output}/.git --work-tree=${Output} add ${Output}/${Host[$i]}-mkdir-remote.log
git --git-dir=${Output}/.git --work-tree=${Output} commit -m "${Host[$i]}: mkdir-remote.log"

touch ${Output}/${Host[$i]}-mysqldump.log
ssh ${Host[$i]} "mysqldump --host=${SqlHost[$i]} --user=${SqlUser[$i]} --password=${SqlPass[$i]} --all-databases > ${RemoteBackupDir[$i]}/${Host[$i]}-data-backup.sql" > ${Output}/${Host[$i]}-mysqldump.log
git --git-dir=${Output}/.git --work-tree=${Output} add ${Output}/${Host[$i]}-mysqldump.log
git --git-dir=${Output}/.git --work-tree=${Output} commit -m "${Host[$i]}: mysqldump.log"

mkdir -p ${LocalDir[$i]}/${Host[$i]} > ${Output}/${Host[$i]}-mkdir-local.log
git --git-dir=${Output}/.git --work-tree=${Output} add ${Output}/${Host[$i]}-mkdir-local.log
git --git-dir=${Output}/.git --work-tree=${Output} commit -m "${Host[$i]}: mkdir-local.log"

rsync -avz --delete --progress -e ssh ${Host[$i]}:${RemoteBackupDir[$i]}/${Host[$i]}-data-backup.sql ${Output} > ${Output}/${Host[$i]}-rsync-sql.log
git --git-dir=${Output}/.git --work-tree=${Output} add ${Output}/${Host[$i]}-rsync-sql.log
git --git-dir=${Output}/.git --work-tree=${Output} add ${Output}/${Host[$i]}-data-backup.sql
git --git-dir=${Output}/.git --work-tree=${Output} commit -m "${Host[$i]}: sql"

rsync -avz --delete --progress -e ssh ${Host[$i]}:${RemoteDir[$i]} ${LocalDir[$i]}/${Host[$i]} > ${Output}/${Host[$i]}-rsync-files.log
git --git-dir=${Output}/.git --work-tree=${Output} add ${Output}/${Host[$i]}-rsync-files.log
git --git-dir=${Output}/.git --work-tree=${Output} commit -m "${Host[$i]}: rsync-files.log"

ssh ${Host[$i]} "rm -f ${RemoteBackupDir[$i]}/${Host[$i]}-data-backup.sql"
