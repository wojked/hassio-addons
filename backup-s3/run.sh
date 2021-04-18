#!/bin/bash

#### VARIABLES ####

CONFIG_PATH=/data/options.json
KEY=$(jq -r .awskey $CONFIG_PATH)
SECRET=$(jq -r .awssecret $CONFIG_PATH)
BUCKET=$(jq -r .bucketname $CONFIG_PATH)
USE_NAME=$(jq -r .usename $CONFIG_PATH)

BACKUP_PATH="/backup"
SYMLINKS_PATH="/symlinks"
SNAPSHOT_FILE="snapshot.json"
SNAPSHOT_FILE_PATH="/$SNAPSHOT_FILE"

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

format_str() {
  local str=${1##*( )}
  local str=${str// /-}
  echo "$str"
}

create_symlinks() {
  for filename in "$BACKUP_PATH"/*.tar; do
    snapshot_json=$(tar -tf "$filename" | grep snapshot.json)
    tar -xf "$filename" "$snapshot_json"

    name_raw=$(jq -r $JQ_NAME "$SNAPSHOT_FILE_PATH")
    prefix_raw=$(get_prefix "$name_raw" ':')

    name_length=${#name_raw}
    prefix_length=${#prefix_raw}
    cut_length=$((prefix_length + 1)) # +1 in order to include the delimiter

    # Ignore files without prefix
    if [[ "$prefix_length" == "$name_length" ]]; then
      log "Skipping \"$name_raw\""
      log "Please use the following format: \"PREFIX: KEY\""
      log "Example: \"DailyBackup: Backup1\""
      log "Result: \"My-Bucket/DailyBackup/Backup1.tar\""

      rm -f "$SNAPSHOT_FILE_PATH"
      continue
    fi

    name=$(format_str "${name_raw:cut_length}")
    prefix=$(format_str "$prefix_raw")

    # Create Symlink
    mkdir -p "$SYMLINKS_PATH/$prefix"
    ln -s "$filename" "$SYMLINKS_PATH/$prefix/$name.tar"

    log "Creating Symlink: $SYMLINKS_PATH/$prefix/$name.tar"

    # Cleanup
    rm -f "$SNAPSHOT_FILE_PATH"
  done
}

#### END FUNCTIONS ####


log "Starting Sync"

log "Configuring AWS credentials"
aws configure set aws_access_key_id "$KEY"
aws configure set aws_secret_access_key "$SECRET"

if [[ "$USE_NAME" == "true" ]]; then
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
