# rsyncBackup
Bash script to do a full system backup -- Intended to be implemented as a cron job for incremental system backup (similar to backintime)

## Installation
Before cloning this project, ensure that the appropriate dependencies are installed on your system. This is a `bash` script that utilizes the `rsync` command line utility to effect a backup of your `/home` directory.

`rsync version 3.2.7 protocol version 31`

The cleanup script (`cleanup.py`) requires python (version `3.11.8`) and uses the `os`, `datetime`, and `pandas` (version `1.5.3`) modules.

To utilize this setup simply clone this project into your target directory:

```
cd <~/the/target/directory>
git clone git@github.com:tlmoore-UniNA/rsyncBackup.git
```

Here `<~/the/target/directory>` is the directory where you would like to download this project folder, e.g. `/home/user/Programs`.

## Configuration

To configure the program, go into the bash script, `backup.sh`, and modify your target directory, i.e. `BACKUP_DIR`. In the script this is set to the location `"/Backup"`, however you may setup any location that you would like.

```
readonly BACKUP_DIR="/Backup" # <- change this line here
```

If you setup a job to cleanup your backups (i.e. to keep only X number of daily backups, Y number of months, and X number of yearly), then be sure to change the directory in the python script as well.


### Setting up a persistant external HD mount

If you want to setup the backup to an external drive that is persistantly mounted to your device, you can easily do so.

First, plugin your external storage (e.g. HD, SSD) into your device. Then, identify the device name with `lsblk`.

```
$ lsblk

NAME        MAJ:MIN  RM  SIZE RO TYPE MOUNTPOINTS
nvme0n1     259:0    0 953.9G  0 disk
├─nvme0n1p1 259:1    0   260M  0 part /boot
├─nvme0n1p2 259:2    0     8G  0 part [SWAP]
└─nvme0n1p3 259:3    0   528G  0 part /
sda           8:0    0   1.8T  0 disk
└─sda1        8:1    0   1.5T  0 part
```

In this example, we have identified `/dev/sda1` as the external drive partitionintended as our backup location. Find the `UUID` for that device using `blkid`.

```
blkid /dev/sda1
```

Create a directory for the persistent mount:
```
sudo mkdir /Backup
```

Mount the drive to that directory:
```
sudo mount /dev/sda1 /Backup
```

Finally, edit your file system table `fstab` to identify that drive. Into `/etc/fstab`, add a line such as:

```
UUID=28cb0bad-5936-4371-970d-affbc1864aea   /Backup ext4    users,rw,auto,nofail,exec
```
