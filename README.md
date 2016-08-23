# CouchDB Replication Management Scripts

## Background

These scripts help us manage CouchDB _replicator jobs on port 5984

There is a mapreduce view to help with displaying the data, this needs to exist on the jobserver, it can be created with replicate_createview.sh


## Setup

create a file in the root named VARS with the following format
JOBSERVER="localhost"
SOURCE="source.server"
DEST="dest.server"
PASSWORD="couchpass"
