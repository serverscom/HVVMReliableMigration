function Select-VM {
    Param (
        [Parameter(ParameterSetName = 'Running', Mandatory, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'Migrating', Mandatory, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'BackingUp', Mandatory, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'Stopped', Mandatory, ValueFromPipeline = $true)]
        [Parameter(ParameterSetName = 'Saved', Mandatory, ValueFromPipeline = $true)]
        [Microsoft.HyperV.PowerShell.VirtualMachine[]]$VM,
        [Parameter(ParameterSetName = 'Running')]
        [Parameter(ParameterSetName = 'Migrating')]
        [Parameter(ParameterSetName = 'BackingUp')]
        [Parameter(ParameterSetName = 'Stopped')]
        [Parameter(ParameterSetName = 'Saved')]
        [switch]$Force,
        [Parameter(ParameterSetName = 'Running', Mandatory)]
        [switch]$Running,
        [Parameter(ParameterSetName = 'Migrating', Mandatory)]
        [switch]$Migrating,
        [Parameter(ParameterSetName = 'BackingUp', Mandatory)]
        [switch]$BackingUp,
        [Parameter(ParameterSetName = 'Stopped', Mandatory)]
        [switch]$Stopped,
        [Parameter(ParameterSetName = 'Saved', Mandatory)]
        [switch]$Saved
    )

    Begin {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

        Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$VM: ''{0}''' -f [string]$VM)
        Write-Debug -Message ('$VM.Name: ''{0}''' -f [string]$VM.Name)
        Write-Debug -Message ('$VM.Id: ''{0}''' -f [string]$VM.Id)
        Write-Debug -Message ('$Running = ${0}' -f $Running)
        Write-Debug -Message ('$Force = ${0}' -f $Force)
        Write-Debug -Message ('$Migrating = ${0}' -f $Migrating)
        Write-Debug -Message ('$BackingUp = ${0}' -f $BackingUp)
        Write-Debug -Message ('$Stopped = ${0}' -f $Stopped)
        Write-Debug -Message ('$Saved = ${0}' -f $Saved)
    }
    Process {
        Write-Debug -Message ('ENTER PROCESS {0}' -f $MyInvocation.MyCommand.Name)

        try {
            Write-Debug -Message ('ENTER PROCESS TRY {0}' -f $MyInvocation.MyCommand.Name)

            Write-Debug -Message ('$VM: ''{0}''' -f [string]$VM)
            Write-Debug -Message ('$VM.Name: ''{0}''' -f [string]$VM.Name)
            Write-Debug -Message ('$VM.Id: ''{0}''' -f [string]$VM.Id)

            foreach ($VMItem in $VM) {
                Write-Debug -Message ('$VMItem: ''{0}''' -f $VMItem)
                Write-Debug -Message ('$VMItem.Name: ''{0}''' -f $VMItem.Name)
                Write-Debug -Message ('$VMItem.Id: ''{0}''' -f $VMItem.Id)

                Write-Debug -Message ('$Running: ''{0}''' -f $Running)
                Write-Debug -Message ('$Migrating: ''{0}''' -f $Migrating)
                Write-Debug -Message ('$BackingUp: ''{0}''' -f $BackingUp)
                Write-Debug -Message ('$Stopped: ''{0}''' -f $Stopped)
                Write-Debug -Message ('$Saved: ''{0}''' -f $Saved)

                Write-Debug -Message ('$ParameterHash = @{{VM = $VMItem, PassThru = $true, Force = ${0}}}' -f $Force)
                $ParameterHash = @{
                    VM       = $VMItem
                    PassThru = $true
                    Force    = $Force
                }
                Write-Debug -Message ($ParameterHash | Out-String)

                Write-Debug -Message '$Result, $VMItem = if ($Running)'
                $Result, $VMItem = if ($Running) {
                    Write-Debug -Message 'Test-VMRunningStatus @ParameterHash'
                    Test-VMRunningStatus @ParameterHash
                }
                elseif ($Migrating) {
                    Write-Debug -Message 'Test-VMMigratingStatus @ParameterHash'
                    Test-VMMigratingStatus @ParameterHash
                }
                elseif ($BackingUp) {
                    Write-Debug -Message 'Test-VMBackingUpStatus @ParameterHash'
                    Test-VMBackingUpStatus @ParameterHash
                }
                elseif ($Stopped) {
                    Write-Debug -Message 'Test-VMStoppedStatus @ParameterHash'
                    Test-VMStoppedStatus @ParameterHash
                }
                elseif ($Saved) {
                    Write-Debug -Message 'Test-VMSavedStatus @ParameterHash'
                    Test-VMSavedStatus @ParameterHash
                }
                Write-Debug -Message ('$VMItem: ''{0}''' -f $VMItem)
                Write-Debug -Message ('$VMItem.Name: ''{0}''' -f $VMItem.Name)
                Write-Debug -Message ('$VMItem.Id: ''{0}''' -f $VMItem.Id)
                Write-Debug -Message ('$Result: ''{0}''' -f $Result)

                Write-Debug -Message 'if ($Result)'
                if ($Result) {
                    Write-Debug -Message '$VMItem'
                    $VMItem
                }
            }

            Write-Debug -Message ('EXIT PROCESS TRY {0}' -f $MyInvocation.MyCommand.Name)
        }
        catch {
            Write-Debug -Message ('ENTER PROCESS CATCH {0}' -f $MyInvocation.MyCommand.Name)

            Write-Debug -Message ('{0}: $PSCmdlet.ThrowTerminatingError($_)' -f $MyInvocation.MyCommand.Name)
            $PSCmdlet.ThrowTerminatingError($_)

            Write-Debug -Message ('EXIT PROCESS CATCH {0}' -f $MyInvocation.MyCommand.Name)
        }
        Write-Debug -Message ('EXIT PROCESS {0}' -f $MyInvocation.MyCommand.Name)
    }
    End {
        Write-Debug -Message ('EXIT {0}' -f $MyInvocation.MyCommand.Name)
    }
}