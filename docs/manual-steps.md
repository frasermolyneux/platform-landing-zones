# [<](../README.md) Manual Steps

## Deploy Principals / Service Connections

This repository contains a [service-connections.ps1](./../scripts/service-connections.ps1) script that contains the configuration to create the deploy principals, set their permissions and create associated service connections in Azure DevOps. This needs to be run manually whenever changed using an account that is `Global Administrator`.

The script is non-destructive so will only perform additive changes, as such removing permissions needs to be done manually.
