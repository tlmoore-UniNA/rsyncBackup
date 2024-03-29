# rsyncBackup
Bash script to do a full system backup -- Intended to be implemented as a cron job for incremental system backup (similar to backintime)

## Installation
Before cloning this project, ensure that the appropriate dependencies are installed on your system. This is a `bash` script that utilizes the `rsync` command line utility to effect a backup of your `/home` directory.

`rsync version 3.2.7 protocol version 31`

To utilize this setup simply clone this project into your target directory:

```
cd <~/the/target/directory>
git clone git@github.com:tlmoore-UniNA/rsyncBackup.git
```

Here `<~/the/target/directory>` is the directory where you would like to download this project folder, e.g. `/home/user/Programs`.

## Configuration

To configure the program, go into the bash script, `backup.sh`, and modify your target directory, i.e. `BACKUP_DIR`. In the script this is set to the location `"/Backup"`, however you may setup any location that you would like
