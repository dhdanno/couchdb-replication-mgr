#!/bin/bash
# Creates our map/reduce view if it does not exist for performing queries

# Load up our variables
source ./VARS

curl -s -X GET http://$JOBSERVER:5986/_replicator/_design/replicator_views/ | grep error

if [ $? -eq 0 ]; then

  echo "no view found, creating"

  curl -s -H 'Content-Type: application/json' -X POST http://couchadmin:$PASSWORD@$JOBSERVER:5986/_replicator -d '{
   "_id": "_design/replicator_views",
   "language": "javascript",
   "views": {
       "by_source": {
           "map": "function(doc) { if (doc.source && doc._rev)  emit(doc.source, doc._rev) }"
       },
       "by_state": {
           "map": "function(doc) { if (doc._replication_state && doc.source)  emit(doc._replication_state, doc.source) }"
       }
   }
  }'

else

  echo "view already exists"

fi
