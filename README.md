[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=blue&style=flat&logo=github&labelColor=32393F&label=MoJ%20Compliant&query=%24.result&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fnetwork-access-control-disaster-recovery)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html#network-access-control-disaster-recovery "Link to report")

# MoJO Network Access Control disaster recovery

*It is recommended to roll forward with a fix than to roll back. If a rollback is still required, follow the steps in this guide*

This repo contains an interactive script which can be used to roll back a corrupt config or container version for the [Network Access Control](https://github.com/ministryofjustice/network-access-control-server) service.

## Prerequisites

- [AWS Vault](https://github.com/99designs/aws-vault#installing) configured for the corrupted environment
- [jq](https://stedolan.github.io/jq/) 

## Recovering from a Disaster
In the event that Grafana has alerted on a disaster scenario, find the correct section and follow the steps provided.

### Corrupt Config 
Identify the corrupt configuration file, this can be either `clients.conf` or `authorised_macs`

1. `aws-vault exec ENV_PROFILE -- make restore-config`
2. At the prompt, enter the environment name (development/pre-production/production)
3. At the second prompt, enter the name of the S3 key to restore
4. You will be given an output of the last five published configs with their `VersionId` and `LastModified`
5. Copy the `VersionId` of the config you wish to restore to
6. At the final prompt, paste the `VersionId`
7. The terminal will exit with the following command: `Successfully rolled back 'authorised_macs'/'clients.conf' to version: VersionId`
8. Kick off a release in the server pipeline to force a rolling deploy where the servers pull in this reverted file.

### Corrupt Container

The latest ECR image is tagged with 'latest'. Untagged images are kept for 14 days before being deleted with a lifecycle policy.
This is to keep storage costs down. It is assumed that if an image has been live for 14 days, it can be considered stable.

If a previous image needs to be restored within this 14 day period, follow the steps below:

1. `aws-vault exec mojo-{ENVIRONMENT}-cli -- make restore-service-container`
2. At the prompt, enter the environment name (development/pre-production/production)
3. At the second prompt, enter the corrupt service name (dns/dhcp)
4. You will be given an output of the last five pushed containers with their `imageDigest` and `imagePushedAt`
5. Copy the `imageDigest` of the container you wish to re-tag as latest
6. At the final prompt, paste the `imageDigest`
7. The terminal will exit with the following command: `Successfully re-tagged image: imageDigest as latest`
8. A rolling deploy will have to be done manually by stopping each of the container and waiting for them to be accepted into service
