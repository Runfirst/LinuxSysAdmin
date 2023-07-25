#!/bin/bash
#
#
#Time
DATE=$( DATE '+%Y-%m-%d_%H_%M_%S' )
#Backup directory
BACKUPDIR="/home/backups"
#Directory that need to backup
SORFILE=/opt
#The name of the backup file 
DESFILE=/home/backups/$SORFILE.$( date '+%Y-%m-%d_%H_%M_%S' ).zip

#Check if the backup directory is exist; if not, create
[ ! -d $BACKUPDIR ] && mkdir -p $BACKUPDIR
cd $BACKUPDIR 


#Backup the directory
tar cvf $DESFILE $SORFFILE &>/dev/null

if [ "$?" == "0" ]
then
    echo $(date +%Y-%m-%d) " tar sucess";
else
    echo $(date +%Y-%m-%d) "tar failed"
    exit 0
fi

#Delete the backup file whick is backuped 3 days ago.
find $BACKUPDIR -type f -ctime +3 |xargs rm -rf

