function Get-VMResourceMapping {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [Microsoft.HyperV.PowerShell.VirtualMachine]$VM
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    Write-Debug -Message ('$VM: ''{0}''' -f $VM.Name)
    Write-Debug -Message ('$VM.Id: ''{0}''' -f $VM.Id)
    Write-Debug -Message ('$VM.Name: ''{0}''' -f $VM.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message '$Path = $VM.Path'
        $ConfigPath = $VM.Path
        Write-Debug -Message ('$ConfigPath = ''{0}''' -f $ConfigPath)

        # Join-Path cannot combine paths on a drive which does not exist on the machine
        Write-Debug -Message ('$VMPath = [System.IO.Path]::Combine(''{0}'',''Virtual Machines'')' -f $ConfigPath)
        $VMPath = [System.IO.Path]::Combine($ConfigPath, 'Virtual Machines')
        Write-Debug -Message ('$VMPath = ''{0}''' -f $VMPath)
        Write-Debug -Message ('$VMPathID = [System.IO.Path]::Combine(''{0}'',''{1}'')' -f $ConfigPath, $VM.Id)
        $VMPathID = [System.IO.Path]::Combine($VMPath, $VM.Id)
        Write-Debug -Message ('$VMPathID = ''{0}''' -f $VMPathID)
        Write-Debug -Message ('$SmartPagingFilePath = [System.IO.Path]::Combine(''{0}'',''Virtual Machines'')' -f $VM.SmartPagingFilePath)
        $SmartPagingFilePath = [System.IO.Path]::Combine($VM.SmartPagingFilePath, 'Virtual Machines')
        Write-Debug -Message ('$SmartPagingFilePath = ''{0}''' -f $SmartPagingFilePath)
        Write-Debug -Message ('$SmartPagingFilePathID = [System.IO.Path]::Combine(''{0}'',''{1}'')' -f $VM.SmartPagingFilePath, $VM.Id)
        $SmartPagingFilePathID = [System.IO.Path]::Combine($SmartPagingFilePath, $VM.Id)
        Write-Debug -Message ('$SmartPagingFilePathID = ''{0}''' -f $SmartPagingFilePathID)

        Write-Debug -Message ('$UndoLogPath = [System.IO.Path]::Combine(''{0}'',''UndoLog Configuration'')' -f $ConfigPath)
        $UndoLogPath = [System.IO.Path]::Combine($ConfigPath, 'UndoLog Configuration')
        Write-Debug -Message ('$UndoLogPath = ''{0}''' -f $UndoLogPath)
        Write-Debug -Message ('$PlannedVirtualMachinesPath = [System.IO.Path]::Combine(''{0}'',''Planned Virtual Machines'')' -f $ConfigPath)
        $PlannedVirtualMachinesPath = [System.IO.Path]::Combine($ConfigPath, 'Planned Virtual Machines')
        Write-Debug -Message ('$PlannedVirtualMachinesPath = ''{0}''' -f $PlannedVirtualMachinesPath)

        # $VM.CheckpointFileLocation is the same as $VM.SnapshotFileLocation
        Write-Debug -Message ('$SnapshotFilePath = [System.IO.Path]::Combine(''{0}'',''Snapshots'')' -f $VM.SnapshotFileLocation)
        $SnapshotFilePath = [System.IO.Path]::Combine($VM.SnapshotFileLocation, 'Snapshots')
        Write-Debug -Message ('$SnapshotFilePath = ''{0}''' -f $SnapshotFilePath)

        Write-Debug -Message '$HardDrivePaths = $VM.HardDrives.Path'
        $HardDrivePaths = $VM.HardDrives.Path
        Write-Debug -Message ('$HardDrivePaths: ''{0}''' -f [string]$HardDrivePaths)
        $HardDriveFolderPaths = foreach ($HardDrivePath in $HardDrivePaths) {
            Write-Debug -Message ('Split-Path -Path ''{0}''' -f $HardDrivePath)
            Split-Path -Path $HardDrivePath
        }
        Write-Debug -Message ('$HardDriveFolderPaths: ''{0}''' -f [string]$HardDriveFolderPaths)
        Write-Debug -Message '$HardDriveFolderPaths = $HardDriveFolderPaths | Select-Object -Unique'
        $HardDriveFolderPaths = $HardDriveFolderPaths | Select-Object -Unique
        Write-Debug -Message ('$HardDriveFolderPaths: ''{0}''' -f [string]$HardDriveFolderPaths)

        $OtherPaths = @(
            $UndoLogPath
            $PlannedVirtualMachinesPath
            $SnapshotFilePath
            $HardDriveFolderPaths
        )
        Write-Debug -Message ('$OtherPaths: ''{0}''' -f [string]$OtherPaths)
        Write-Debug -Message '$OtherPaths = $OtherPaths | Select-Object -Unique'
        $OtherPaths = $OtherPaths | Select-Object -Unique
        Write-Debug -Message ('$OtherPaths: ''{0}''' -f [string]$OtherPaths)

        $Result = @{
            ConfigPath = $ConfigPath
            VMPathID = $VMPathID
            VMPath = $VMPath
            SmartPagingFilePathID = $SmartPagingFilePathID
            SmartPagingFilePath = $SmartPagingFilePath
            OtherPaths = $OtherPaths
            HostName   = $VM.ComputerName
        }
        Write-Debug -Message ('$Result: ''{0}''' -f ($Result | Out-String))

        Write-Debug -Message '$Result'
        $Result

        Write-Debug -Message ('EXIT TRY {0}' -f $MyInvocation.MyCommand.Name)
    }
    catch {
        Write-Debug -Message ('ENTER CATCH {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('{0}: $PSCmdlet.ThrowTerminatingError($_)' -f $MyInvocation.MyCommand.Name)
        $PSCmdlet.ThrowTerminatingError($_)

        Write-Debug -Message ('EXIT CATCH {0}' -f $MyInvocation.MyCommand.Name)
    }

    Write-Debug -Message ('EXIT {0}' -f $MyInvocation.MyCommand.Name)
}