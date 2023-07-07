---
external help file: HVVMReliableMigration-help.xml
Module Name: HVVMReliableMigration
online version:
schema: 2.0.0
---

# Move-VMReliably

## SYNOPSIS
This is the main function of the module. Use it to migrate virtual machines without hassle.

## SYNTAX

### ByHost
```
Move-VMReliably -SourceVMHost <Host> -DestinationVMHost <Host> -Path <String> [-Timeout <Int32>] [-MaxAttempts <Int32>] [-MaxParallelMigrations <Int32>] [-BackupThreshold <TimeSpan>] [-Bulletproof] [-CrashOnUnmigratable] [-SessionID <Guid>] [<CommonParameters>]
```

### ByVM
```
Move-VMReliably -VM <VM[]> -DestinationVMHost <Host> -Path <String> [-Timeout <Int32>] [-MaxAttempts <Int32>] [-MaxParallelMigrations <Int32>] [-BackupThreshold <TimeSpan>] [-Bulletproof] [-CrashOnUnmigratable] [-SessionID <Guid>] [<CommonParameters>]
```

## DESCRIPTION
This is a main function in the module. Use it to migrate Hyper-V virtual machines hassle free.

## EXAMPLES

### Example 1
```powershell
$VMs = Get-VM -ComputerName SRVHV01 | Where-Object -FilterScript {$_.Name -like 'SRVSP*'}
Move-VMReliably -VM $VMs -DestinationVMHost (Get-VMHost SRVHV02) -Path 'D:\VirtualMachines'
```

Migrates all virtual machines, which name starts with "SRVSP*", from a Hyper-V host SRVHV01 to SRVHV02, placing them into the "D:\VirtualMachines" folder at SRVHV02.

### Example 2
```powershell
Move-VMReliably -SourceVMHost (Get-VMHost SRVHV01) -DestinationVMHost (Get-VMHost SRVHV02) -Path 'D:\VirtualMachines' -PreserveSourceVhdPathDriveLetter -PutInASubfolder
```

Migrates all virtual machines from a Hyper-V host SRVHV01 to SRVHV02, placing each one to the separate subfolder "D:\Virtual Machines\\\<Virtual Machine Name>" at SRVHV02.
VHDs attached to the virtual machine will be placed on the target host according to the hypervisor's volume letters of their source paths: VM's disks "C:\Hyper-V\VM1\Disk1.vhdx", "D:\Hyper-V\VM1\Disk2.vhdx" from source hypervisor will be moved to "C:\VirtualMachines\\\<VirtualMachineName>\Disk1.vhdx" and "D:\VirtualMachines\\\<VirtualMachineName>\Disk2.vhdx" on the destination host.

### Example 3
```powershell
$VMs = Get-VM -ComputerName SRVHV01 | Where-Object -FilterScript {$_.Name -like 'SRVSP*'}
Move-VMReliably -VM $VMs -DestinationVMHost (Get-VMHost SRVHV02) -Path 'D:\VirtualMachines' -BackupThreshold (New-Object -TypeName 'System.TimeSpan' -ArgumentList @(2, 0, 0))
```

Migrates all virtual machines, which name starts with "SRVSP*", from a Hyper-V host SRVHV01 to SRVHV02, placing them into the "D:\VirtualMachines" folder at SRVHV02. If any machine is in the backing up state, the function will wait for no more than two hours to let the backup process to finish.

## PARAMETERS

### -VM
A virtual machine objects which you would like to migrate.

```yaml
Type: Microsoft.HyperV.PowerShell.VirtualMachine[]
Parameter Sets: ByVM
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SourceVMHost
If you want to migrate ALL VMs from a Hyper-V host, you can just specify its VMHost object, instead of passing each VM at the host to the `-VM` parameter.

```yaml
Type: Microsoft.HyperV.PowerShell.VMHost
Parameter Sets: ByHost
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DestinationVMHost
A VMHost object of a Hyper-V host where you want to migrate virtual machines.

```yaml
Type: Microsoft.HyperV.PowerShell.VMHost
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
A location on the destination host where virtual machines should be stored.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```


### -MaxAttempts
If a migration of a VM fails, the function will try again. This parameter specifies the maximum number of attempts.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxParallelMigrations
Sets the maximum number of parallel live migrations. If the parameter is not set, the minimum value between LiveMigrationMaximum properties of all affected hypervisors is used. If the parameter is set but exceeds that minimum value, the minimum value is used.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timeout
When the migration queue is full, the function will wait some time before checking the queue's status again. This parameter specifies how long will it wait.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupThreshold
If a VM is backing up - you cannot migrate it. In that case, the function will ignore the for some time. This parameters specifies for how long the function will wait for the backup to complete before declaring the VM unmigratable.

```yaml
Type: TimeSpan
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Bulletproof
Enabling this parameter refreshes VM status more frequently, but it is a performance hit.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CrashOnUnmigratable
By default, at the end, the function returns all machines which it was unable to migrate. Enabling this parameter changes the function's behavior to raise an exception as soon as an unmigratable machine is found.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReturnSourceVMs
When enabled, the function returns a hashtable, containing a list of virtual machines it tried to move (SourceVMs), and a list of virtual machines which failed to move (UnmigratableVMs), if there are any.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PutInASubfolder
When used, places virtual machines in subfolders, named as VMs themselves, therefore mimicking SCVMM behavior.
Requires access to WinRM on the target computer and access to the Win32_Directory WMI class.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreserveSourceVhdPathDriveLetter
Forces the module to place virtual hard disks of the migrated virtual machines to the partitions with the same drive letters as on the source host, if those partitions exist. The full destination paths of the virtual hard disks are defined by the subdirectories specified in the Path parameter and the behavior of the "PutInASubfoler" parameter.

```yaml
Type: Switch
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MigrationJobGetMaxAttempts
When an asynchronous migration of a VM starts, it needs some time before appearing in the list of jobs. Before proceeding to the next VM, the function tries to find the migration job it has just created in the list. This parameter specifies the maximum number of such attempts.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MigrationJobGetTimeout
When an asynchronous migration of a VM starts, it needs some time before appearing in the list of jobs. Before proceeding to the next VM, the function tries to find the migration job it has just created in the list. This parameter specifies how long the function will wait between retries (`-MigrationJobGetMaxAttempts` parameter).

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SessionID
The `$SessionID` variable ensures uniqueness of migration jobs names if several `Move-VMReliably` instances run in the same PowerShell session. By default a random GUID is used for this parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: [guid]::NewGuid().ToString()
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Microsoft.HyperV.PowerShell.VirtualMachine[]
### Microsoft.HyperV.PowerShell.VMHost

## OUTPUTS

### Microsoft.HyperV.PowerShell.VirtualMachine

## NOTES

## RELATED LINKS
