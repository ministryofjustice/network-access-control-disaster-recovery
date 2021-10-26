#!/bin/bash
set -euo pipefail

read -p "Which environment are you restoring? 'development'/'pre-production'/'production': " env
if [ !"$env" = "development" ] || [ !"$env" = "pre-production" ] || [ !"$env" = "production" ]; then
   echo "Please enter a valid environment";
   exit 1;
fi

read -p "Which file you want to restore? 'clients.conf'/'authorised_macs': " key

aws s3api list-object-versions --bucket mojo-$env-nac-config-bucket --prefix $key | jq '[.Versions [] | {VersionId: .VersionId, LastModified: .LastModified}][:5]'

read -p "Copy and paste the VersionId to roll back to: " version
aws s3api get-object --bucket mojo-$env-nac-config-bucket --key $key --version-id "${version}" $key > /dev/null
aws s3api put-object --bucket mojo-$env-nac-config-bucket --key $key --body $key > /dev/null
rm -f $key
echo "Successfully rolled back $key to version: $version"
exit
