#!/bin/sh
# This script is designed to set up replication for the kazoo MODB databases, as these come into
# existence each month, and cease to be written to at the end of each month... we should create and delete 
# the respective replication jobs once a month per jobserver

# Load up our variables
source ./VARS

# Check 2 arguments are given #
if [ $# -lt 2 ]; then echo "Usage: $0 -a <account>"; exit ;fi

CURRMONTH=`date +%Y%m`
LASTMONTH=`date +%Y%m -d "-1 month"`
NEXTMONTH=`date +%Y%m -d "+1 month"`

#echo $LASTMONTH; echo $NEXTMONTH; echo $CURRMONTH

if [ $1 == "-a" ]; then
  C="$2-$CURRMONTH"
  N="$2-$NEXTMONTH"
#  exit
else
  echo "Incorrect switch, use -a to specify an account DB for modb management"
  exit
fi

# Remove current months MODB replication job
echo "Removing $C replication job on $JOBSERVER"

REV=`curl -s http://$JOBSERVER:5986/_replicator/_all_docs | jq -r '.rows[] | select(.key=="'$C'") | .value.rev'`
RESULT=`curl -s -H 'Content-Type: application/json' -X DELETE http://couchadmin:$PASSWORD@$JOBSERVER:5986/_replicator/$C?rev=$REV`
echo $RESULT

# Add next months MODB replication job
echo "Adding $N replication job on $JOBSERVER"

curl -H 'Content-Type: application/json' -X POST http://couchadmin:$PASSWORD@$JOBSERVER:5986/_replicator -d '{"source":"http://couchadmin:'$PASSWORD'@'$SOURCE':5984/'$N'","target":"http://couchadmin:'$PASSWORD'@'$DEST':5984/'$N'", "continuous":true, "create_target":true}'






