#!/bin/bash

#### VARIABLES ####

CONFIG_PATH=/data/options.json

KEY=$(bashio::config 'awskey')
SECRET=$(bashio::config 'awssecret')
BUCKET=$(bashio::config 'bucketname')
USE_NAME=$(bashio::config 'usename')

BACKUP_PATH="/backup"
SYMLINKS_PATH="/symlinks"
SNAPSHOT_FILE="snapshot.json"
SNAPSHOT_FILE_PATH="$BACKUP_PATH/$SNAPSHOT_FILE"

JQ_NAME=".name" # format: "PREFIX: KEY"

#### END VARIABLES ####


#### FUNCTIONS ####

log() {
  now="$(date +'%d/%m/%Y - %H:%M:%S')"
  echo "$now |  ---> $1"
}

get_prefix() {
  IFS="$2"                   # delimiter
  read -ra ADDR <<< "$1"     # $1 is read into an array as tokens separated by IFS
  IFS=' '                    # reset to default value after usage
  echo "${ADDR[0]}"
}

cleanup() {
  rm -f "$SNAPSHOT_FILE_PATH*"
  rm -rf "$SYMLINKS_PATH"
}

create_symlinks() {
  for filename in "$BACKUP_PATH"/*.tar; do
    tar -zxvf "$filename" $SNAPSHOT_FILE

    name=$(jq -r $JQ_NAME $SNAPSHOT_FILE_PATH)
    prefix=$(get_prefix "$name" ':')
    cut_length=$((${#prefix} + 1))

    # Ignore files without prefix
    if [[ "$cut_length" == 1 ]]; then
      rm -f $SNAPSHOT_FILE_PATH
      continue
    fi

    # Create Symlink
    mkdir -p "$SYMLINKS_PATH/$prefix"
    ln -s "$BACKUP_PATH/$filename" "$SYMLINKS_PATH/$prefix/${name:cut_length}.tar"

    # Cleanup
    rm -f $SNAPSHOT_FILE_PATH
  done
}

#### END FUNCTIONS ####


log "Starting Sync"

log "Configuring AWS credentials"
aws configure set aws_access_key_id "$KEY"
aws configure set aws_secret_access_key "$SECRET"

if [[ -n "$USE_NAME" ]]; then
  log "Using Snapshots names"
  # Cleanup of previous runs
  cleanup

  log "Creating Symlinks"
  create_symlinks

  log "Syncing Backup Archives"
  aws s3 sync "$SYMLINKS_PATH" "s3://$BUCKET/" --quiet

  cleanup
else
  log "Continuing without Snapshot names"
  log "Syncing Backup Archives"
  aws s3 sync "$BACKUP_PATH" "s3://$BUCKET/" --quiet
fi

log "Done"
