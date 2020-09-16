# HVVMReliableMigration

This module solves three problems which apply to VM migrations in a shared-nothing Hyper-V infrastructure (Azure-like):

1. Live-migration limit.
    When you try to live-migrate a number of VMs which exceeds the hosts' live-migration limit, you have to manually watch running migration jobs and queue new ones as soon as a migration slot becomes available. This module automatically watches available migration slots and queues machines for migration.

2. It is impossible to migrate a machine which is currently backing up. The module relieves you from the burden of waiting and waits and retries migrations for you.

3. Migrated VMs leave clutter of folders at the source server. This module cleans them up.

The module works around those problems by introducing additional checks and correction actions to the migration process. Also, if something happens during a migration, it retries again, several times.

## Exported functions
* [Move-VMReliably](docs/Move-VMReliably.md)

## Module-wide variables
There are several variables defined in the .psm1-file, which are used by the module's functions as default values for parameters:

`[int]$ModuleWideMigrationMaxAttempts` - default value for **Move-VMReliably**'s `-MaxAttempts` parameter

`[int]$ModuleWideMigrationTimeout` - default value for **Move-VMReliably**'s `-Timeout` parameter

`[int]$ModuleWideMigrationJobGetTimeout` - default value for **Move-VMReliably**'s `-MigrationJobGetTimeout` parameter

`[int]$ModuleWideMigrationJobGetMaxAttempts` - default value for **Move-VMReliably**'s `-MigrationJobGetMaxAttempts` parameter

`[System.TimeSpan]$ModuleWideBackupThreshold` - default value for **Move-VMReliably**'s `-BackupThreshold` parameter

## Loading variables from an external source
All module-wide variables can be redefined with a `Config.ps1` file, located in the module's root folder. Just put variable definitions in there as you would do with any other PowerShell script. You may find an example of a config file `Config-Example.ps1` in the module's root folder.

## Limitations
* Only one-to-one source-destination host mapping is supported.