function Move-HVVM {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [Microsoft.HyperV.PowerShell.VirtualMachine]$VM,
        [Parameter(Mandatory)]
        [string]$HostName,
        [Parameter(Mandatory)]
        [string]$Path,
        [switch]$PutInASubfolder
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    Write-Debug -Message ('$VM: ''{0}''' -f $VM.Name)
    Write-Debug -Message ('$VM.Id: ''{0}''' -f $VM.Id)
    Write-Debug -Message ('$VM.Name: ''{0}''' -f $VM.Name)
    Write-Debug -Message ('$HostName = ''{0}''' -f $HostName)
    Write-Debug -Message ('$Path = ''{0}''' -f $Path)
    Write-Debug -Message ('$PutInASubfolder = ${0}' -f $PutInASubfolder)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message '$VMResourceMapping = Get-VMResourceMapping -VM $VM'
        $VMResourceMapping = Get-VMResourceMapping -VM $VM
        Write-Debug -Message ('$VMResourceMapping: ''{0}''' -f ($VMResourceMapping | Out-String))

        Write-Debug -Message 'if ($PutInASubfolder)'
        if ($PutInASubfolder) {
            Write-Debug -Message ('$Path = Get-VMSubfolderPath -VMName ''{0}'' -HostName ''{1}'' -Path ''{2}''' -f $VM.Name, $HostName, $Path)
            $Path = Get-VMSubfolderPath -VMName $VM.Name -HostName $HostName -Path $Path
            Write-Debug -Message ('$Path = ''{0}''' -f $Path)
        }

        Write-Debug -Message ('$null = Move-VM -VM $VM -DestinationHost ''{0}'' -IncludeStorage -DestinationStoragePath ''{1}''' -f $HostName, $Path)
        $null = Move-VM -VM $VM -DestinationHost $HostName -IncludeStorage -DestinationStoragePath $Path

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