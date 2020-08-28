function Test-VMLiveMigrationEligibility {

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param (
        [Parameter(Mandatory)]
        [Microsoft.HyperV.PowerShell.VirtualMachine]$VM,
        [Parameter(Mandatory)]
        [Microsoft.HyperV.PowerShell.VMHost]$DestinationHost
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$VM: ''{0}''' -f [string]$VM)
        Write-Debug -Message ('$VM.Name: ''{0}''' -f $VM.Name)
        Write-Debug -Message ('$VM.Id: ''{0}''' -f $VM.Id)
        Write-Debug -Message ('$VM.PrimaryOperationalStatus: ''{0}''' -f $VM.PrimaryOperationalStatus)
        Write-Debug -Message ('$VM.SecondaryOperationalStatus: ''{0}''' -f $VM.SecondaryOperationalStatus)
        Write-Debug -Message ('$VM.Status: ''{0}''' -f $VM.Status)
        Write-Debug -Message ('$VM.State: ''{0}''' -f $VM.State)
        Write-Debug -Message ('$DestinationHost: ''{0}''' -f [string]$DestinationHost)

        $VMStatesMigrating = @(
            [Microsoft.HyperV.PowerShell.VMOperationalStatus]::MigratingVirtualMachine
            [Microsoft.HyperV.PowerShell.VMOperationalStatus]::StorageMigrationPhaseOne
            [Microsoft.HyperV.PowerShell.VMOperationalStatus]::StorageMigrationPhaseTwo
            [Microsoft.HyperV.PowerShell.VMOperationalStatus]::MigratingPlannedVm
        )
        Write-Debug -Message ('$VMStatesMigrating: ''{0}''' -f [string]$VMStatesMigrating)

        $VMStatesRunning = @(
            [Microsoft.HyperV.PowerShell.VMState]::Running
        )
        Write-Debug -Message ('$VMStatesRunning: ''{0}''' -f [string]$VMStatesRunning)

        $VMStatesEligible = @(
            [Microsoft.HyperV.PowerShell.VMOperationalStatus]::Ok
        )
        Write-Debug -Message ('$VMStatesEligible: ''{0}''' -f [string]$VMStatesEligible)

        Write-Debug -Message '$Result = $false'
        $Result = $false
        Write-Debug -Message ('$Result: ''{0}''' -f [string]$Result)
        Write-Debug -Message '$Reason = ''OK'''
        $Reason = 'OK'
        Write-Debug -Message ('$Reason = ''{0}''' -f $Reason)

        Write-Debug -Message '$SourceHostName = $VM.ComputerName'
        $SourceHostName = $VM.ComputerName
        Write-Debug -Message ('$SourceHostName = ''{0}''' -f $SourceHostName)

        Write-Debug -Message '$DestinationHostName = $DestinationHost.Name'
        $DestinationHostName = $DestinationHost.Name
        Write-Debug -Message ('$DestinationHostName = ''{0}''' -f $DestinationHostName)

        Write-Debug -Message ('$SourceVMs = Get-VM -ComputerName ''{0}''' -f $SourceHostName)
        $SourceVMs = Get-VM -ComputerName $SourceHostName
        Write-Debug -Message ('$SourceVMs: ''{0}''' -f [string]$SourceVMs)
        Write-Debug -Message ('$DestinationVMs = Get-VM -ComputerName ''{0}''' -f $DestinationHostName)
        $DestinationVMs = Get-VM -ComputerName $DestinationHostName
        Write-Debug -Message ('$DestinationVMs: ''{0}''' -f [string]$DestinationVMs)

        Write-Debug -Message 'if ($VM.Id -notin $SourceVMs.Id)'
        if ($VM.Id -notin $SourceVMs.Id) {
            Write-Debug -Message '$Reason = ''NotFound'''
            $Reason = 'NotFound'
        }
        elseif ($VM.Id -in $DestinationVMs.Id) {
            Write-Debug -Message '$Reason = ''Migrated'''
            $Reason = 'Migrated'
        }
        elseif ($VM.SecondaryOperationalStatus -in $VMStatesMigrating) {
            Write-Debug -Message '$Reason = ''Migrating'''
            $Reason = 'Migrating'
        }
        elseif ($VM.State -notin $VMStatesRunning) {
            Write-Debug -Message '$Reason = ''NotRunning'''
            $Reason = 'NotRunning'
        }
        else {
            Write-Debug -Message '$IsVMBackingUp = Test-VMBackingUpStatus -VM $VM'
            $IsVMBackingUp = Test-VMBackingUpStatus -VM $VM
            Write-Debug -Message ('$IsVMBackingUp: ''{0}''' -f [string]$IsVMBackingUp)
            Write-Debug -Message 'if ($IsVMBackingUp)'
            if ($IsVMBackingUp) {
                Write-Debug -Message '$Reason = ''BackingUp'''
                $Reason = 'BackingUp'
            }
            elseif ($VM.PrimaryOperationalStatus -notin $VMStatesEligible) {
                Write-Debug -Message '$Reason = $VM.PrimaryOperationalStatus'
                $Reason = $VM.PrimaryOperationalStatus
            }
            else {
                Write-Debug -Message '$Result = $true'
                $Result = $true
            }
        }
        Write-Debug -Message ('$Reason = ''{0}''' -f $Reason)
        Write-Debug -Message ('$Result: ''{0}''' -f [string]$Result)

        Write-Debug -Message ('@{{Result = {0}}}; $Reason = ''{1}''; Status = ''{2}''' -f [string]$Result, $Reason, [string]$VM.Status)
        @{
            Result = $Result
            Reason = $Reason
            Status = $VM.Status
        }

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