#!/bin/sh
# Lists all _replicate jobs from jobserver - Depends on the "replicator_views" view
# Daniel Korel 2016
# Usage: replicate_list.sh -a [all jobs] -s [single job]

# Load up our variables
source ./VARS

# Check at least 2 arguments are given #
if [ $# -lt 1 ]; then echo "Usage: replicate_list.sh -a [all jobs by source] -s [all jobs by state]"; exit ;fi

# Find a single doc through a custom view and delete by name
if [ $1 == "-a" ]; then

  curl -Ss http://$JOBSERVER:5986/_replicator/_design/replicator_views/_view/by_source
  exit

elif [ $1 == "-s" ]; then

  curl -Ss http://$JOBSERVER:5986/_replicator/_design/replicator_views/_view/by_state
  exit

fi

