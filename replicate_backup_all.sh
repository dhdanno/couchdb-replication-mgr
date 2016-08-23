#!/bin/sh
# Supply a source server to enumerate it's _all_dbs and create a standalone (temporal)
# replication job from SOURCE to DEST on JOBSERVER

# Load up our variables
source ./VARS

# Get all DB's
# Get all minus MODB's

trim_array=( $(curl -Ss http://$SOURCE:5984/_all_dbs | jq -r '.[]' | grep -v "\-20[0-9][0-9][0-9][0-9]" ) )
#Construct an array like this

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

#echo $trim_array

# Process
for i in "${trim_array[@]}"
do

     r=$(rawurlencode $i)
     echo "Creating replication job for '$r'"
     printf "\n"
     
     # Enable Replication from SOURCE to DEST on JOBSERVER

     curl -H 'Content-Type: application/json' -X POST http://couchadmin:$PASSWORD@$JOBSERVER:5986/_replicator -d '{"source":"http://couchadmin:'$PASSWORD'@'$SOURCE':5984/'$r'","target":"http://couchadmin:'$PASSWORD'@'$DEST':5984/'$r'", "continuous":false, "create_target":true}'

     #sleep 1;
done


exit
