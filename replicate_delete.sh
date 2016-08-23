#!/bin/sh
# Deletes all _replicate jobs from jobserver
# Daniel Korel 2016

# Load up our variables
source ./VARS

SOURCEHOST=`hostname -f` # This should be our own FQDN. The source replication server defined on JOBSERVER
URL="http://$JOBSERVER:5986/_replicator/_all_docs"

# Check at least 2 arguments are given #
if [ $# -lt 2 ]; then echo "Usage: replicate_delete.sh -a a (ALL JOBS DELETED) | -s <single_job>"; exit ;fi

# -a specifies ALL JOBS are to be deleted on JOBSERVER
if [ $1 == "-a" ]; then
  read -p "Deletes all replication jobs on $JOBSERVER Are you sure? Type y/n" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]
  then
      exit
  fi

  # Enumerate all replicator jobs minus the design doc into args array
  args=()
  while read key
    do
      if [ $key != "_design%2f_replicator" ]; then
        args+=("$key")
      fi
  done <<< "$(curl -Ss  "$URL" | jq -r '.rows[].key | @uri')"

  #echo "${args[@]}"

  # Perform deletion for each doc in the args array
  for i in "${args[@]}"
  do
       echo "Deleting Replicator $i"
       # need to supply the rev for this doc id
      REV=`curl -s http://$JOBSERVER:5986/_replicator/_all_docs | jq -r '.rows[] | select(.key=="'$i'") | .value.rev'`
      RESULT=`curl -s -H 'Content-Type: application/json' -X DELETE http://couchadmin:$PASSWORD@$JOBSERVER:5986/_replicator/$i?rev=$REV`

       echo $RESULT
       #sleep 1;
  done

# Find a single doc through a custom view and delete by name
elif [ $1 == "-s" ]; then

  rawurlencode() {
    local string="${1}"
    local strlen=${#string}
    local encoded=""
    local pos c o

    for (( pos=0 ; pos<strlen ; pos++ )); do
      c=${string:$pos:1}
      case "$c" in
         [-_.~a-zA-Z0-9] ) o="${c}" ;;
         * )               printf -v o '%%%02x' "'$c"
      esac
      encoded+="${o}"
    done
    echo "${encoded}"    # You can either set a return variable (FASTER)
    REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
  }


  # Use a couch map view with double urlencoded db name to fetch the database by name, grab the rev and delete
  # TODO: use jq to parse this output so its not quite so nasty
  RAW=`curl -Ss -X GET 'http://'$JOBSERVER':5986/_replicator/_design/replicator_views/_view/by_source?key="http://couchadmin:'$PASSWORD'@'$SOURCEHOST':5984/'$( rawurlencode "$2" )'"' | head -n2 | tail -n1`
  REV=`echo $RAW | cut -d ':' -f 7 | cut -d '"' -f 2`

  echo $RAW

  ID=`echo $RAW | cut -d ':' -f 2 | cut -d '"' -f 2`

  #echo $ID

  # We need the ID to perform a delete op
  RESULT=`curl -s -H 'Content-Type: application/json' -X DELETE http://couchadmin:$PASSWORD@$JOBSERVER:5986/_replicator/$ID?rev=$REV`
  echo $RESULT

  exit

fi



