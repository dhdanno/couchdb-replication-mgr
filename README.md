# CouchDB Replication Management Scripts

## Background

These scripts help us manage CouchDB _replicator jobs on port 5986


## Usage

The various scripts are fairly self explanatory. You can create, list and delete various types of jobs.

In testing we found that continious replication (jobs posted to the _replicator database on 5986) are the most reliable on BigCouch. I did not have much luck with non-continious jobs.


## Setup

create a file in the root named VARS with the following format
```JOBSERVER="localhost"
SOURCE="source.server"
DEST="dest.server"
PASSWORD="couchpass"```


There is a mapreduce view to help with displaying the data, this needs to exist on the jobserver, it can be created with replicate_createview.sh

## Notes

...
