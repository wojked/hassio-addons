#!/bin/sh

KEY=`jq -r .awskey /data/options.json`
SECRET=`jq -r .awssecret /data/options.json`
BUCKET=`jq -r .bucketname /data/options.json`

now="$(date +'%d/%m/%Y - %H:%M:%S')"

echo $now

aws configure set aws_access_key_id $KEY
aws configure set aws_secret_access_key $SECRET

aws s3 sync /backup/ s3://$BUCKET/ --quiet

echo "Done"
