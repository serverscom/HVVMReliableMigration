function Move-HVVM {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [Microsoft.HyperV.PowerShell.VirtualMachine]$VM,
        [Parameter(Mandatory)]
        [string]$HostName,
        [Parameter(Mandatory)]
        [string]$Path,
        [switch]$ForceSingleDestinationPath,
        [switch]$PutInASubfolder
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    Write-Debug -Message ('$VM: ''{0}''' -f $VM.Name)
    Write-Debug -Message ('$VM.Id: ''{0}''' -f $VM.Id)
    Write-Debug -Message ('$VM.Name: ''{0}''' -f $VM.Name)
    Write-Debug -Message ('$HostName = ''{0}''' -f $HostName)
    Write-Debug -Message ('$Path = ''{0}''' -f $Path)
    Write-Debug -Message ('$ForceSingleDestinationPath = ${0}' -f $ForceSingleDestinationPath)
    Write-Debug -Message ('$PutInASubfolder = ${0}' -f $PutInASubfolder)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message '$VMResourceMapping = Get-VMResourceMapping -VM $VM'
        $VMResourceMapping = Get-VMResourceMapping -VM $VM
        Write-Debug -Message ('$VMResourceMapping: ''{0}''' -f ($VMResourceMapping | Out-String))
        Write-Debug -Message ('$VMResourceMapping.HardDrivePaths.Count: {0}' -f $VMResourceMapping.HardDrivePaths.Count)

        Write-Debug -Message 'if (-not $ForceSingleDestinationPath -and $VMResourceMapping.HardDrivePaths.Count -gt 1)'
        if (-not $ForceSingleDestinationPath -and $VMResourceMapping.HardDrivePaths.Count -gt 1) {
            Write-Debug -Message ('${0}' -f [string](-not $ForceSingleDestinationPath -and $VMResourceMapping.HardDrivePaths.Count -gt 1))
            Write-Debug -Message '$CustomDestinationVHDPaths = Get-CustomDestinationVHDPaths -VMName $VM.Name -SourceVMVHDPaths $VMResourceMapping.HardDrivePaths -DestinationHostName $HostName -DestinationPath $Path -PutInASubfolder:$PutInASubfolder'
            $CustomDestinationVHDPaths = Get-CustomDestinationVHDPaths -VMName $VM.Name -SourceVMVHDPaths $VMResourceMapping.HardDrivePaths -DestinationHostName $HostName -DestinationPath $Path -PutInASubfolder:$PutInASubfolder
            Write-Debug -Message ('$CustomDestinationVHDPaths: ''{0}''' -f ($CustomDestinationVHDPaths | Out-String))
        }
        else {
            Write-Debug -Message ('${0}' -f [string](-not $ForceSingleDestinationPath -and $VMResourceMapping.HardDrivePaths.Count -gt 1))
            Write-Debug -Message '$CustomDestinationVHDPaths = $null'
            $CustomDestinationVHDPaths = $null
        }

        Write-Debug -Message 'if ($PutInASubfolder)'
        if ($PutInASubfolder) {
            Write-Debug -Message ('${0}' -f [string]($PutInASubfolder))
            Write-Debug -Message '$Path = Get-VMSubfolderPath -VMName $VM.Name -HostName $HostName -Path $Path'
            Write-Debug -Message ('$Path = Get-VMSubfolderPath -VMName ''{0}'' -HostName ''{1}'' -Path ''{2}''' -f $VM.Name, $HostName, $Path)
            $Path = Get-VMSubfolderPath -VMName $VM.Name -HostName $HostName -Path $Path
            Write-Debug -Message ('$Path = ''{0}''' -f $Path)
        }
        else {
            Write-Debug -Message ('${0}' -f [string]($PutInASubfolder))
        }

        Write-Debug -Message 'if ($CustomDestinationVHDPaths -and -not $ForceSingleDestinationPath)'
        if ($CustomDestinationVHDPaths -and -not $ForceSingleDestinationPath) {
            Write-Debug -Message ('${0}' -f [string]($CustomDestinationVHDPaths -and -not $ForceSingleDestinationPath))
            Write-Debug -Message '$null = Move-VM -VM $VM -DestinationHost $HostName -IncludeStorage -VirtualMachinePath $VMDestinationPaths.VirtualMachinePath -SnapshotFilePath $VMDestinationPaths.SnapshotFilePath -Vhds $CustomDestinationVHDPaths'
            $null = Move-VM -VM $VM -DestinationHost $HostName -VirtualMachinePath $Path -SnapshotFilePath $Path -Vhds $CustomDestinationVHDPaths
        }
        else {
            Write-Debug -Message ('${0}' -f [string]($CustomDestinationVHDPaths -and -not $ForceSingleDestinationPath))
            Write-Debug -Message '$null = Move-VM -VM $VM -DestinationHost $HostName -IncludeStorage -DestinationStoragePath $Path'
            $null = Move-VM -VM $VM -DestinationHost $HostName -IncludeStorage -DestinationStoragePath $Path
        }

        Write-Debug -Message ('$VMResourceMapping: ''{0}''' -f ($VMResourceMapping | Out-String))
        Write-Debug -Message 'Remove-EmptyVMFolder -ResourceMapping $VMResourceMapping'
        Remove-EmptyVMFolder -ResourceMapping $VMResourceMapping

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
