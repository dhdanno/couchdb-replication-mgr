#!/bin/sh
# Supply a file with a list of databases or a single database to enable replication from SOURCE to DEST on JOBSERVER

# Load up our variables
source ./VARS

# Check 3 arguments are given #
if [ $# -lt 2 ]; then echo "Usage: $0 -b <filename> | -s <databasename>"; exit ;fi

if [ $1 == "-b" ]; then
  if [ ! -f $2 ]; then
    echo "File $2 does not exist"
  else
    readarray -t db_array < ./$2
  fi
elif [ $1 == "-s" ]; then
  db_array=( $2 )
else
  echo "Incorrect switch, use -b to specify a filename for bulk import, or -s for a single database"
  exit
fi

# Process
for i in "${db_array[@]}"
do
     echo "Creating replication job for '$i'"
     :
     # Enable Replication from SOURCE to DEST on JOBSERVER
     curl -H 'Content-Type: application/json' -X POST http://couchadmin:$PASSWORD@$JOBSERVER:5986/_replicator -d '{"source":"http://couchadmin:'$PASSWORD'@'$SOURCE':5984/'$i'","target":"http://couchadmin:'$PASSWORD'@'$DEST':5984/'$i'", "continuous":true, "create_target":true}'

     sleep 1;
done

