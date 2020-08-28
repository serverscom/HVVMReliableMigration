function Move-VMReliably {

    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName = 'ByHost', Mandatory)]
        [Microsoft.HyperV.PowerShell.VMHost]$SourceVMHost,
        [Parameter(ParameterSetName = 'ByVM', Mandatory)]
        [Microsoft.HyperV.PowerShell.VirtualMachine[]]$VM,
        [Parameter(ParameterSetName = 'ByHost', Mandatory)]
        [Parameter(ParameterSetName = 'ByVM', Mandatory)]
        [Microsoft.HyperV.PowerShell.VMHost]$DestinationVMHost,
        [Parameter(ParameterSetName = 'ByHost', Mandatory)]
        [Parameter(ParameterSetName = 'ByVM', Mandatory)]
        [string]$Path,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Timeout = $ModuleWideMigrationTimeout,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$MaxAttempts = $ModuleWideMigrationMaxAttempts,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$MaxParallelMigrations,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$MigrationJobGetTimeout = $ModuleWideMigrationJobGetTimeout,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$MigrationJobGetMaxAttempts = $ModuleWideMigrationJobGetMaxAttempts,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [System.TimeSpan]$BackupThreshold = $ModuleWideBackupThreshold,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [switch]$Bulletproof,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [switch]$CrashOnUnmigratable,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [switch]$ReturnSourceVMs,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [switch]$PutInASubfolder,
        [Parameter(ParameterSetName = 'ByHost')]
        [Parameter(ParameterSetName = 'ByVM')]
        [string]$SessionID = [guid]::NewGuid().ToString() # Because .Guid property is twice slower
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$SourceVMHost: ''{0}''' -f [string]$SourceVMHost)
        Write-Debug -Message ('$VM: ''{0}''' -f [string]$VM.Name)
        Write-Debug -Message ('$DestinationVMHost: ''{0}''' -f [string]$DestinationVMHost)
        Write-Debug -Message ('$Path = ''{0}''' -f $Path)
        Write-Debug -Message ('$Timeout = {0}' -f $Timeout)
        Write-Debug -Message ('$MaxAttempts = {0}' -f $MaxAttempts)
        Write-Debug -Message ('$MaxParallelMigrations = {0}' -f $MaxParallelMigrations)
        Write-Debug -Message ('$MigrationJobGetTimeout = {0}' -f $MigrationJobGetTimeout)
        Write-Debug -Message ('$MigrationJobGetMaxAttempts = {0}' -f $MigrationJobGetMaxAttempts)
        Write-Debug -Message ('$BackupThreshold: ''{0}''' -f [string]$BackupThreshold)
        Write-Debug -Message ('$Bulletproof: ''{0}''' -f [string]$Bulletproof)
        Write-Debug -Message ('$CrashOnUnmigratable: ''{0}''' -f [string]$CrashOnUnmigratable)
        Write-Debug -Message ('$ReturnSourceVMs = ${0}' -f $ReturnSourceVMs)
        Write-Debug -Message ('$PutInASubfolder = ${0}' -f $PutInASubfolder)
        Write-Debug -Message ('$SessionID = ''{0}''' -f $SessionID)

        Write-Debug -Message 'if ($VM)'
        if ($VM) {
            Write-Debug -Message '$UniqueVMHosts = $VM.ComputerName | Select-Object -Unique'
            $UniqueVMHosts = $VM.ComputerName | Select-Object -Unique
            Write-Debug -Message ('$UniqueVMHosts: ''{0}''' -f [string]$UniqueVMHosts)
            Write-Debug -Message ('$UniqueVMHosts.Count: {0}' -f $UniqueVMHosts.Count)
            Write-Debug -Message 'if ($UniqueVMHosts.Count -eq 1)'
            if ($UniqueVMHosts.Count -eq 1) {
                # Right now the function supports moving VMs between two hosts only
                Write-Debug -Message ('$SourceVMHost = Get-VMHost -ComputerName ''{0}''' -f $UniqueVMHosts)
                $SourceVMHost = Get-VMHost -ComputerName $UniqueVMHosts
                Write-Debug -Message ('$SourceVMHost: ''{0}''' -f [string]$SourceVMHost)
            }
            elseif ($UniqueVMHosts.Count -lt 1) {
                $Message = ('Somehow there are no unique VMHosts: {0}' -f [string]$UniqueVMHosts.Name)
                $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.Management.Automation.PSNotSupportedException' -ArgumentList $Message), 'PSNotSupportedException', [System.Management.Automation.ErrorCategory]::InvalidData, $UniqueVMHosts)))
            }
            else {
                $Message = ('Input VMs are from several VMHosts: {0}' -f [string]$UniqueVMHosts.Name)
                $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.Management.Automation.PSNotSupportedException' -ArgumentList $Message), 'PSNotSupportedException', [System.Management.Automation.ErrorCategory]::InvalidData, $UniqueVMHosts)))
            }
        }

        Write-Debug -Message '$SourceHostName = $SourceVMHost.Name'
        $SourceHostName = $SourceVMHost.Name
        Write-Debug -Message ('$SourceHostName = ''{0}''' -f $SourceHostName)
        Write-Debug -Message '$DestinationHostName = $DestinationVMHost.Name'
        $DestinationHostName = $DestinationVMHost.Name
        Write-Debug -Message ('$DestinationHostName = ''{0}''' -f $DestinationHostName)

        Write-Debug -Message 'if ($SourceVMHost -ne $DestinationVMHost)'
        if ($SourceVMHost -ne $DestinationVMHost) {

            Write-Debug -Message 'if (-not $VM)'
            if (-not $VM) {
                Write-Debug -Message ('$VM = Get-VM -ComputerName ''{0}''' -f $SourceHostName)
                $VM = Get-VM -ComputerName $SourceHostName
            }
            Write-Debug -Message ('$VM: ''{0}''' -f [string]$VM.Name)

            Write-Debug -Message 'if ($VM)'
            if ($VM) {
                Write-Debug -Message '[System.Collections.ArrayList]$UnmigratableVMs = @()'
                [System.Collections.ArrayList]$UnmigratableVMs = @()
                Write-Debug -Message '[System.Collections.ArrayList]$BackingUpVMs = @()'
                [System.Collections.ArrayList]$BackingUpVMs = @()
                Write-Debug -Message '[System.Collections.ArrayList]$VMMigrationRetryInfo = @()'
                [System.Collections.ArrayList]$VMMigrationRetryInfo = @()

                Write-Debug -Message '$SourceVMHostLiveMigrationMaximum = $SourceVMHost.MaximumVirtualMachineMigrations'
                $SourceVMHostLiveMigrationMaximum = $SourceVMHost.MaximumVirtualMachineMigrations
                Write-Debug -Message ('$SourceVMHostLiveMigrationMaximum = {0}' -f $SourceVMHostLiveMigrationMaximum)

                Write-Debug -Message '$DestinationVMHostLiveMigrationMaximum = $DestinationVMHost.MaximumVirtualMachineMigrations'
                $DestinationVMHostLiveMigrationMaximum = $DestinationVMHost.MaximumVirtualMachineMigrations
                Write-Debug -Message ('$DestinationVMHostLiveMigrationMaximum = {0}' -f $DestinationVMHostLiveMigrationMaximum)
                Write-Debug -Message ('$LiveMigrationMaximum = (({0}, {1}) | Measure-Object -Minimum).Minimum' -f $SourceVMHostLiveMigrationMaximum, $DestinationVMHostLiveMigrationMaximum)
                $LiveMigrationMaximum = (($SourceVMHostLiveMigrationMaximum, $DestinationVMHostLiveMigrationMaximum) | Measure-Object -Minimum).Minimum
                Write-Debug -Message ('$LiveMigrationMaximum = {0}' -f $LiveMigrationMaximum)

                Write-Debug -Message ('$MaxParallelMigrations = {0}' -f $MaxParallelMigrations)
                Write-Debug -Message 'if ($MaxParallelMigrations)'
                if ($MaxParallelMigrations) {
                    Write-Debug -Message ('$LiveMigrationMaximum = (({0}, {1}) | Measure-Object -Minimum).Minimum' -f $LiveMigrationMaximum, $MaxParallelMigrations)
                    $LiveMigrationMaximum = (($LiveMigrationMaximum, $MaxParallelMigrations) | Measure-Object -Minimum).Minimum
                }
                Write-Debug -Message ('$LiveMigrationMaximum = {0}' -f $LiveMigrationMaximum)

                Write-Debug -Message ('$ReturnSourceVMs = ${0}' -f $ReturnSourceVMs)
                Write-Debug -Message ('if ($ReturnSourceVMs)')
                if ($ReturnSourceVMs) {
                    Write-Debug -Message '$FirstRun = $true'
                    $FirstRun = $true
                    Write-Debug -Message ('$FirstRun = ${0}' -f $FirstRun)
                }

                do {
                    Write-Debug -Message ('$PsCmdlet.ParameterSetName: ''{0}''' -f $PsCmdlet.ParameterSetName)
                    switch ($PsCmdlet.ParameterSetName) {
                        'ByHost' {
                            Write-Debug -Message '$Filter = {$_.Id -notin $UnmigratableVMs}'
                            $Filter = {$_.Id -notin $UnmigratableVMs}
                        }
                        'ByVM' {
                            Write-Debug -Message '$Filter = {$_.Id -in $VM.Id -and $_.Id -notin $UnmigratableVMs}'
                            $Filter = {$_.Id -in $VM.Id -and $_.Id -notin $UnmigratableVMs}
                        }
                    }
                    Write-Debug -Message ('$Filter = {{{0}}}' -f $Filter)

                    Write-Debug -Message ('$SourceVMs = Get-VM -ComputerName ''{0}'' | Where-Object -FilterScript {{{1}}}' -f $SourceHostName, $Filter)
                    $SourceVMs = Get-VM -ComputerName $SourceHostName | Where-Object -FilterScript $Filter # Getting those VMs of which we care about
                    Write-Debug -Message ('$SourceVMs: ''{0}''' -f [string]$SourceVMs.Name)
                    Write-Debug -Message ('$SourceVMs.Id: ''{0}''' -f [string]$SourceVMs.Id)
                    Write-Debug -Message 'if ($SourceVMs)'
                    if ($SourceVMs) {
                        Write-Debug -Message ('$ReturnSourceVMs = ${0}' -f $ReturnSourceVMs)
                        Write-Debug -Message ('if ($ReturnSourceVMs)')
                        if ($ReturnSourceVMs) {
                            Write-Debug -Message ('$FirstRun = ${0}' -f $FirstRun)
                            Write-Debug -Message 'if ($FirstRun)'
                            if ($FirstRun) {
                                Write-Debug -Message '$SourceVMsOriginal = $SourceSCVMs.Clone()'
                                $SourceVMsOriginal = $SourceVMs.Clone()
                                Write-Debug -Message ('$SourceVMsOriginal: ''{0}''' -f [string]$SourceVMsOriginal.Name)
                                Write-Debug -Message '$FirstRun = $false'
                                $FirstRun = $false
                                Write-Debug -Message ('$FirstRun = ${0}' -f $FirstRun)
                            }
                        }

                        Write-Debug -Message ('$SourceVMsMigrating = $SourceVMs | Select-VM -Migrating -Force:${0}' -f $Bulletproof)
                        $SourceVMsMigrating = $SourceVMs | Select-VM -Migrating -Force:$Bulletproof
                        Write-Debug -Message ('$SourceVMsMigrating: ''{0}''' -f [string]$SourceVMsMigrating.Name)
                        Write-Debug -Message '$SourceVMsNotMigrating = $SourceVMs | Where-Object -FilterScript {$_.Id -notin $SourceVMsMigrating.Id}'
                        $SourceVMsNotMigrating = $SourceVMs | Where-Object -FilterScript {$_.Id -notin $SourceVMsMigrating.Id}
                        Write-Debug -Message ('$SourceVMsNotMigrating: ''{0}''' -f [string]$SourceVMsNotMigrating.Name)
                        Write-Debug -Message ('$SourceVMsNotMigratingRunning = $SourceVMsNotMigrating | Select-VM -Running -Force:${0}' -f $Bulletproof)
                        $SourceVMsNotMigratingRunning = $SourceVMsNotMigrating | Select-VM -Running -Force:$Bulletproof
                        Write-Debug -Message ('$SourceVMsNotMigratingRunning: ''{0}''' -f [string]$SourceVMsNotMigratingRunning.Name)
                        Write-Verbose -Message ('VMs left to migrate: {0}' -f [string]$SourceVMs.Name)

                        Write-Debug -Message 'if ($SourceVMsNotMigratingRunning)'
                        if ($SourceVMsNotMigratingRunning) {
                            Write-Debug -Message '$SourceVMsToMigrate = $SourceVMsNotMigratingRunning'
                            $SourceVMsToMigrate = $SourceVMsNotMigratingRunning # We TRY to migrate VMs which have just been running
                        }
                        else {
                            Write-Debug -Message '$SourceVMsToMigrate = $SourceVMsNotMigrating'
                            $SourceVMsToMigrate = $SourceVMsNotMigrating
                        }

                        Write-Debug -Message ('$SourceVMsToMigrate: ''{0}''' -f [string]$SourceVMsToMigrate.Name)
                        foreach ($VMItem in $SourceVMsToMigrate) {
                            # If a VM is migrating already - we don't care about it
                            Write-Debug -Message ('$VMItem.Name: ''{0}''' -f $VMItem.Name)
                            Write-Debug -Message ('$VMItem.Id: ''{0}''' -f $VMItem.Id)

                            Write-Debug -Message ('$SourceVMHostVMs = Get-VM -ComputerName ''{0}''' -f $SourceHostName)
                            $SourceVMHostVMs = Get-VM -ComputerName $SourceHostName
                            Write-Debug -Message ('$SourceVMHostVMs: ''{0}''' -f [string]$SourceVMsNotMigratingRunning.Name)
                            Write-Debug -Message ('$DestinationVMHostVMs = Get-VM -ComputerName ''{0}''' -f $DestinationHostName)
                            $DestinationVMHostVMs = Get-VM -ComputerName $DestinationHostName
                            Write-Debug -Message ('$DestinationVMHostVMs: ''{0}''' -f [string]$DestinationVMHostVMs.Name)

                            Write-Debug -Message ('$SourceVMHostMigratingVMs = $SourceVMHostVMs | Select-VM -Migrating -Force:${0}' -f $Bulletproof)
                            $SourceVMHostMigratingVMs = $SourceVMHostVMs | Select-VM -Migrating -Force:$Bulletproof
                            Write-Debug -Message ('$SourceVMHostMigratingVMs: ''{0}''' -f [string]$SourceVMHostMigratingVMs.Name)
                            Write-Debug -Message ('$DestinationVMHostMigratingVMs = $DestinationVMHostVMs | Select-VM -Migrating -Force:${0}' -f $Bulletproof)
                            $DestinationVMHostMigratingVMs = $DestinationVMHostVMs | Select-VM -Migrating -Force:$Bulletproof
                            Write-Debug -Message ('$DestinationVMHostMigratingVMs: ''{0}''' -f [string]$DestinationVMHostMigratingVMs.Name)
                            Write-Debug -Message ('$VMHostMigratingVMs = {0} + {1}' -f $SourceVMHostMigratingVMs.Count, $DestinationVMHostMigratingVMs.Count)
                            $VMHostMigratingVMsCount = $SourceVMHostMigratingVMs.Count + $DestinationVMHostMigratingVMs.Count
                            Write-Debug -Message ('$VMHostMigratingVMsCount = {0}' -f $VMHostMigratingVMsCount)

                            Write-Debug -Message '$CurrentLiveMigrationCount = $VMHostMigratingVMsCount'
                            $CurrentLiveMigrationCount = $VMHostMigratingVMsCount
                            Write-Debug -Message ('$CurrentLiveMigrationCount = {0}' -f $CurrentLiveMigrationCount)

                            Write-Debug -Message ('$LiveMigrationMaximum = {0}' -f $LiveMigrationMaximum)
                            Write-Debug -Message 'if ($CurrentLiveMigrationCount -lt $LiveMigrationMaximum)'
                            if ($CurrentLiveMigrationCount -lt $LiveMigrationMaximum) {
                                # If the migration queue is not full (if it is full, we do no care who filled it up)

                                Write-Debug -Message '$VirtualMachineLiveMigrationEligibility = Test-VMLiveMigrationEligibility -VM $VMItem -DestinationHost $DestinationVMHost'
                                $VirtualMachineLiveMigrationEligibility = Test-VMLiveMigrationEligibility -VM $VMItem -DestinationHost $DestinationVMHost
                                Write-Debug -Message ('$VirtualMachineLiveMigrationEligibility.Result: ''{0}''' -f $VirtualMachineLiveMigrationEligibility.Result)
                                Write-Debug -Message ('$VirtualMachineLiveMigrationEligibility.Reason: ''{0}''' -f $VirtualMachineLiveMigrationEligibility.Reason)

                                Write-Debug -Message 'if ($VirtualMachineLiveMigrationEligibility.Result -or $VirtualMachineLiveMigrationEligibility.Reason -eq ''NotRunning'')'
                                if ($VirtualMachineLiveMigrationEligibility.Result -or $VirtualMachineLiveMigrationEligibility.Reason -eq 'NotRunning') {
                                    Write-Debug -Message ('$VMMigrationRetryInfo: ''{0}''' -f [string]$VMMigrationRetryInfo)
                                    Write-Debug -Message ('$VMMigrationRetryInfoCount = ($VMMigrationRetryInfo | Where-Object -FilterScript {{$_ -eq ''{0}''}}).Count' -f $VMItem.Id)
                                    $VMMigrationRetryInfoCount = ($VMMigrationRetryInfo | Where-Object -FilterScript {$_ -eq $VMItem.Id}).Count
                                    Write-Debug -Message ('$VMMigrationRetryInfoCount = {0}' -f $VMMigrationRetryInfoCount)
                                    Write-Debug -Message ('$MaxAttempts = {0}' -f $MaxAttempts)
                                    Write-Debug -Message 'if ($VMMigrationRetryInfoCount -ge $MaxAttempts)'
                                    if ($VMMigrationRetryInfoCount -ge $MaxAttempts) {
                                        Write-Verbose -Message ('VM {0} is unmigratable' -f $VMItem.Id)
                                        Write-Debug -Message ('$CrashOnUnmigratable: ''{0}''' -f $CrashOnUnmigratable)
                                        Write-Debug -Message 'if ($CrashOnUnmigratable)'
                                        if ($CrashOnUnmigratable) {
                                            $Message = ('Tried to migrate VM {0} {1} times - did not succeed' -f $VMItem.Id, $VMMigrationRetryInfoCount)
                                            $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.ServiceModel.Channels.RetryException' -ArgumentList $Message), 'RetryException', [System.Management.Automation.ErrorCategory]::OperationTimeout, $VMItem)))
                                        }
                                        else {
                                            Write-Debug -Message ('$null = $UnmigratableVMs.Add(''{0}'')' -f $VMItem.Id)
                                            $null = $UnmigratableVMs.Add($VMItem.Id)
                                        }
                                    }
                                }

                                Write-Debug -Message ('$UnmigratableVMs: ''{0}''' -f [string]$UnmigratableVMs)
                                Write-Debug -Message ('$VMItem.Id: ''{0}''' -f $VMItem.Id)
                                Write-Debug -Message 'if ($VMItem.Id -notin $UnmigratableVMs)'
                                if ($VMItem.Id -notin $UnmigratableVMs) {
                                    Write-Debug -Message 'if ($VirtualMachineLiveMigrationEligibility.Result)'
                                    if ($VirtualMachineLiveMigrationEligibility.Result) {
                                        Write-Debug -Message ('$VMItem.ComputerName: ''{0}''' -f $VMItem.ComputerName)
                                        Write-Debug -Message ('$DestinationHostName = ''{0}''' -f $DestinationHostName)
                                        Write-Debug -Message 'if ($VMItem.ComputerName -ne $DestinationHostName)'
                                        if ($VMItem.ComputerName -ne $DestinationHostName) {
                                            # Better safe than sorry
                                            Write-Debug -Message ('$null = $VMMigrationRetryInfo.Add(''{0}'')' -f $VMItem.Id)
                                            $null = $VMMigrationRetryInfo.Add($VMItem.Id)
                                            Write-Debug -Message ('$VMMigrationRetryInfo: ''{0}''' -f [string]$VMMigrationRetryInfo)
                                            Write-Debug -Message ('$VMMigrationRetryInfoCount = ($VMMigrationRetryInfo | Where-Object -FilterScript {{$_ -eq ''{0}''}}).Count' -f $VMItem.Id)
                                            $VMMigrationRetryInfoCount = ($VMMigrationRetryInfo | Where-Object -FilterScript {$_ -eq $VMItem.Id}).Count
                                            Write-Debug -Message ('$VMMigrationRetryInfoCount = {0}' -f $VMMigrationRetryInfoCount)

                                            Write-Debug -Message ('$JobName = ''HVMIG/{{0}}/{{1}}/{{2}}'' -f ''{0}'', ''{1}'', ''{2}''' -f $SessionID, $VMItem.Id, $VMMigrationRetryInfoCount)
                                            $JobName = 'HVMIG/{0}/{1}/{2}' -f $SessionID, $VMItem.Id, $VMMigrationRetryInfoCount
                                            Write-Debug -Message ('$JobName = ''{0}''' -f $JobName)

                                            $ScriptBlock = {
                                                Param (
                                                    $VM,
                                                    $HostName,
                                                    $Path,
                                                    $PutInASubfolder,
                                                    $Definition,
                                                    $DebugPreference,
                                                    $ErrorActionPreference
                                                )

                                                Set-Item -Path 'Function:\Move-HVVM' -Value $Definition
                                                Move-HVVM -VM $VM -HostName $HostName -Path $Path -PutInASubfolder:$PutInASubfolder
                                            }
                                            Write-Debug -Message ('$ScriptBlock = ''{{{0}}}''' -f $ScriptBlock)

                                            Write-Debug -Message '$MoveFunction = Get-Item -Path ''Function:\Move-HVVM'''
                                            $MoveFunction = Get-Item -Path 'Function:\Move-HVVM'
                                            Write-Debug -Message ('$MoveFunction: ''{0}''' -f $MoveFunction)
                                            $MoveFunctionDefinition = $MoveFunction.Definition
                                            Write-Debug -Message ('$MoveFunctionDefinition: ''{0}''' -f $MoveFunctionDefinition)

                                            Write-Verbose -Message ('Trying to live-migrate a VM {0} from {1} to {2}' -f $VMItem.Id, $VMItem.ComputerName, $DestinationHostName)
                                            try {
                                                Write-Debug -Message ('$null = Start-ThreadJob -Name ''{0}'' -ScriptBlock $ScriptBlock -ArgumentList ($VMItem, ''{1}'', ''{2}'', ${3}, $MoveFunctionDefinition, ''{4}'', ''5'')' -f $JobName, $DestinationHostName, $Path, $PutInASubfolder, $DebugPreference, $ErrorActionPreference)
                                                $null = Start-ThreadJob -Name $JobName -ScriptBlock $ScriptBlock -ArgumentList ($VMItem, $DestinationHostName, $Path, $PutInASubfolder, $MoveFunctionDefinition, $DebugPreference, $ErrorActionPreference)
                                            }
                                            catch {
                                                Write-Debug -Message ($_)
                                                Write-Debug -Message ('Exception.HResult: {0}' -f $_.Exception.HResult)
                                                Write-Debug -Message 'Continue'
                                                Continue
                                            }

                                            Write-Debug -Message ('$MigrationJobGetMaxAttempts = {0}' -f $MigrationJobGetMaxAttempts)
                                            Write-Debug -Message 'for ($MigrationJobGetCounter = 0; $MigrationJobGetCounter -lt $MigrationJobGetMaxAttempts; $MigrationJobGetCounter++)'
                                            for ($MigrationJobGetCounter = 0; $MigrationJobGetCounter -lt $MigrationJobGetMaxAttempts; $MigrationJobGetCounter++) {
                                                Write-Debug -Message ('$MigrationJobGetCounter = {0}' -f $MigrationJobGetCounter)
                                                Write-Debug -Message '$VMMigratingStatus = Test-VMMigratingStatus -VM $VMItem -Force'
                                                $VMMigratingStatus = Test-VMMigratingStatus -VM $VMItem -Force
                                                Write-Debug -Message ('$VMMigratingStatus = ${0}' -f $VMMigratingStatus)
                                                Write-Debug -Message 'if (-not $VMMigratingStatus)'
                                                if (-not $VMMigratingStatus) {
                                                    Write-Debug -Message ('Start-Sleep -Seconds {0}' -f $MigrationJobGetTimeout)
                                                    Start-Sleep -Seconds $MigrationJobGetTimeout
                                                }
                                                else {
                                                    Write-Debug -Message 'break'
                                                    break
                                                }
                                            }

                                            Write-Debug -Message '$LastVMWasPoweredDown = $false'
                                            $LastVMWasPoweredDown = $false
                                            Write-Debug -Message ('$LastVMWasPoweredDown = ${0}' -f $LastVMWasPoweredDown)

                                            Write-Debug -Message ('$BackingUpVMs: ''{0}''' -f [string]$BackingUpVMs)
                                            Write-Debug -Message ('$VMItem.Id: ''{0}''' -f $VMItem.Id)
                                            Write-Debug -Message 'if ($BackingUpVMs.VM -contains $VMItem.Id)'
                                            if ($BackingUpVMs.VM -contains $VMItem.Id) {
                                                Write-Debug -Message ('$BackingUpVMDescription = $BackingUpVMs | Where-Object -FilterScript {{$_.VM -eq ''{0}''}}' -f $VMItem.Id)
                                                $BackingUpVMDescription = $BackingUpVMs | Where-Object -FilterScript {$_.VM -eq $VMItem.Id}
                                                Write-Debug -Message ('$BackingUpVMDescription: ''{0}''' -f [string]$BackingUpVMDescription)
                                                Write-Debug -Message '$null = $BackingUpVMs.Remove($BackingUpVMDescription)'
                                                $null = $BackingUpVMs.Remove($BackingUpVMDescription)
                                                Write-Debug -Message ('$BackingUpVMs.VM: ''{0}''' -f [string]$BackingUpVMs.VM)
                                            }
                                        }
                                    }
                                    else {
                                        Write-Verbose -Message ('Skipping VM {0} this time because: {1}' -f $VMItem.Id, $VirtualMachineLiveMigrationEligibility.Reason)
                                        switch ($VirtualMachineLiveMigrationEligibility.Reason) {
                                            'BackingUp' {
                                                Write-Debug -Message ('$BackingUpVMs.VM: ''{0}''' -f [string]$BackingUpVMs.VM)
                                                Write-Debug -Message ('$VMItem.Id: ''{0}''' -f $VMItem.Id)
                                                Write-Debug -Message 'if ($BackingUpVMs.VM -contains $VMItem.Id)'
                                                if ($BackingUpVMs.VM -contains $VMItem.Id) {
                                                    Write-Debug -Message ('$BackingUpVMDescription = $BackingUpVMs | Where-Object -FilterScript {{$_.VM -eq ''{0}''}}' -f $VMItem.Id)
                                                    $BackingUpVMDescription = $BackingUpVMs | Where-Object -FilterScript {$_.VM -eq $VMItem.Id}
                                                    Write-Debug -Message '$BackupAddDateTime = $BackingUpVMDescription.DateTime'
                                                    $BackupAddDateTime = $BackingUpVMDescription.DateTime
                                                    Write-Debug -Message ('$BackupAddDateTime: ''{0}''' -f [string]$BackupAddDateTime)
                                                    Write-Debug -Message '$CurrentDateTime = Get-Date'
                                                    $CurrentDateTime = Get-Date
                                                    Write-Debug -Message ('$CurrentDateTime: ''{0}''' -f [string]$CurrentDateTime)
                                                    Write-Debug -Message '$BackupDateTimeThreshold = $BackupAddDateTime + $BackupThreshold'
                                                    $BackupDateTimeThreshold = $BackupAddDateTime + $BackupThreshold
                                                    Write-Debug -Message ('$BackupDateTimeThreshold: ''{0}''' -f [string]$BackupDateTimeThreshold)
                                                    Write-Debug -Message 'if ($CurrentDateTime -gt $BackupDateTimeThreshold)'
                                                    if ($CurrentDateTime -gt $BackupDateTimeThreshold) {
                                                        Write-Verbose -Message ('VM {0} is unmigratable' -f $VMItem.Id)
                                                        if ($CrashOnUnmigratable) {
                                                            $Message = ('VM {0} is in backing up state for more than {1} already' -f $VMItem.Id, [string]$BackupThreshold)
                                                            $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.TimeoutException' -ArgumentList $Message), 'TimeoutException', [System.Management.Automation.ErrorCategory]::OperationTimeout, $VMItem)))
                                                        }
                                                        else {
                                                            Write-Debug -Message ('$null = $UnmigratableVMs.Add(''{0}'')' -f $VMItem.Id)
                                                            $null = $UnmigratableVMs.Add($VMItem.Id)
                                                            Write-Debug -Message ('$UnmigratableVMs: ''{0}''' -f [string]$UnmigratableVMs)
                                                            Write-Debug -Message '$null = $BackingUpVMs.Remove($BackingUpVMDescription)'
                                                            $null = $BackingUpVMs.Remove($BackingUpVMDescription)
                                                            Write-Debug -Message ('$BackingUpVMs.VM: ''{0}''' -f [string]$BackingUpVMs.VM)
                                                        }
                                                    }
                                                }
                                                else {
                                                    Write-Debug -Message '$CurrentDateTime = Get-Date'
                                                    $CurrentDateTime = Get-Date
                                                    Write-Debug -Message ('$CurrentDateTime: ''{0}''' -f [string]$CurrentDateTime)
                                                    Write-Debug -Message ('$null = $BackingUpVMs.Add(@{{VM = ''{0}''; DateTime = $CurrentDateTime}})' -f $VMItem.Id)
                                                    $null = $BackingUpVMs.Add(
                                                        @{
                                                            VM       = $VMItem.Id
                                                            DateTime = $CurrentDateTime
                                                        }
                                                    )
                                                    Write-Debug -Message ('$BackingUpVMs.VM: ''{0}''' -f [string]$BackingUpVMs.VM)
                                                }
                                            }
                                            'NotRunning' {
                                                Write-Debug -Message ('$SourceVMs.Status: ''{0}''' -f [string]$SourceVMs.Status)
                                                Write-Debug -Message ('$SourceVMsRunning = $SourceVMs | Select-VM -Running -Force:${0}' -f $Bulletproof)
                                                $SourceVMsRunning = $SourceVMs | Select-VM -Running -Force:$Bulletproof
                                                Write-Debug -Message ('$SourceVMsRunning: ''{0}''' -f [string]$SourceVMsRunning.Name)
                                                Write-Debug -Message ('$SourceVMsMigrating = $SourceVMs | Select-VM -Migrating -Force:${0}' -f $Bulletproof)
                                                $SourceVMsMigrating = $SourceVMs | Select-VM -Migrating -Force:$Bulletproof
                                                Write-Debug -Message ('$SourceVMsMigrating: ''{0}''' -f [string]$SourceVMsMigrating.Name)
                                                Write-Debug -Message 'if (-not ($SourceVMsRunning -or $SourceVMsMigrating))'
                                                if (-not ($SourceVMsRunning -or $SourceVMsMigrating)) {
                                                    # We do not want to move PoweredDown VMs while there's anything in the queue. We also want to migrate them as last as possible.
                                                    Write-Debug -Message ('$null = $VMMigrationRetryInfo.Add(''{0}'')' -f $VMItem.Id)
                                                    $null = $VMMigrationRetryInfo.Add($VMItem.Id)
                                                    Write-Debug -Message ('$VMMigrationRetryInfo: ''{0}''' -f [string]$VMMigrationRetryInfo)
                                                    Write-Verbose -Message ('Trying to migrate a powered-down VM {0} from {1} to {2}' -f $VMItem.Id, $VMItem.ComputerName, $DestinationHostName)
                                                    Write-Debug -Message ('Move-HVVM -VM $VMItem -HostName ''{0}'' -Path ''{1}'' -PutInASubfolder:${2}' -f $DestinationHostName, $Path, $PutInASubfolder)
                                                    Move-HVVM -VM $VMItem -HostName $DestinationHostName -Path $Path -PutInASubfolder:$PutInASubfolder
                                                    Write-Debug -Message '$LastVMWasPoweredDown = $true'
                                                    $LastVMWasPoweredDown = $true
                                                    Write-Debug -Message ('$LastVMWasPoweredDown = ${0}' -f $LastVMWasPoweredDown)
                                                }
                                            }
                                            'OK' {
                                                Write-Debug -Message ('$null = $UnmigratableVMs.Add(''{0}'')' -f $VMItem.Id)
                                                $null = $UnmigratableVMs.Add($VMItem.Id)
                                                Write-Debug -Message ('$UnmigratableVMs: ''{0}''' -f [string]$UnmigratableVMs)
                                                Write-Debug -Message ('$BackingUpVMs.VM: ''{0}''' -f [string]$BackingUpVMs.VM)
                                                Write-Debug -Message ('$VMItem.Id: ''{0}''' -f $VMItem.Id)
                                                Write-Debug -Message 'if ($BackingUpVMs.VM -contains $VMItem.Id)'
                                                if ($BackingUpVMs.VM -contains $VMItem.Id) {
                                                    Write-Debug -Message ('$BackingUpVMDescription = $BackingUpVMs | Where-Object -FilterScript {{$_.VM -eq ''{0}''}}' -f $VMItem.Id)
                                                    $BackingUpVMDescription = $BackingUpVMs | Where-Object -FilterScript {$_.VM -eq $VMItem.Id}
                                                    Write-Debug -Message ('$BackingUpVMDescription: ''{0}''' -f [string]$BackingUpVMDescription)
                                                    Write-Debug -Message '$null = $BackingUpVMs.Remove($BackingUpVMDescription)'
                                                    $null = $BackingUpVMs.Remove($BackingUpVMDescription)
                                                    Write-Debug -Message ('$BackingUpVMs.VM: ''{0}''' -f [string]$BackingUpVMs.VM)
                                                }
                                                Write-Verbose -Message ('VM {0} is unmigratable because of an unsupported status: {1}' -f $VMItem.Id, $VirtualMachineLiveMigrationEligibility.Status)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Write-Debug -Message ('$LastVMWasPoweredDown = ${0}' -f $LastVMWasPoweredDown)
                        Write-Debug -Message 'if (-not $LastVMWasPoweredDown)' # No need to wait if the last job was synchronous
                        if (-not $LastVMWasPoweredDown) {
                            Write-Debug -Message ('Start-Sleep -Seconds {0}' -f $Timeout)
                            Start-Sleep -Seconds $Timeout
                        }
                    }

                    Write-Debug -Message ('$SourceVMs: ''{0}''' -f [string]$SourceVMs.Name)
                    Write-Debug -Message ('$SourceVMs.Id: ''{0}''' -f [string]$SourceVMs.Id)
                    Write-Debug -Message 'while ($SourceVMs)'
                }
                while ($SourceVMs)

                Write-Debug -Message '$ReturnUnmigratableVMs = $false'
                $ReturnUnmigratableVMs = $false
                Write-Debug -Message ('$ReturnUnmigratableVMs = ${0}' -f $ReturnUnmigratableVMs)

                Write-Debug -Message ('$UnmigratableVMs: ''{0}''' -f [string]$UnmigratableVMs)
                Write-Debug -Message 'if ($UnmigratableVMs)'
                if ($UnmigratableVMs) {
                    Write-Debug -Message ('$UnmigratableVMs.Count: {0}' -f $UnmigratableVMs.Count)
                    Write-Debug -Message 'if ($UnmigratableVMs.Count -gt 0)'
                    if ($UnmigratableVMs.Count -gt 0) {
                        Write-Debug -Message ('$UnmigratableVMs: ''{0}''' -f [string]$UnmigratableVMs.Name)

                        Write-Debug -Message '$ReturnUnmigratableVMs = $true'
                        $ReturnUnmigratableVMs = $true
                        Write-Debug -Message ('$ReturnUnmigratableVMs = ${0}' -f $ReturnUnmigratableVMs)
                    }
                }

                Write-Debug -Message ('$ReturnUnmigratableVMs = ${0}' -f $ReturnUnmigratableVMs)
                Write-Debug -Message ('$UnmigratableVMs: ''{0}''' -f [string]$UnmigratableVMs.Name)
                Write-Debug -Message ('$ReturnSourceVMs = ${0}' -f $ReturnSourceVMs)
                Write-Debug -Message ('if ($ReturnSourceVMs)')
                if ($ReturnSourceVMs) {
                    Write-Debug -Message ('$SourceVMsOriginal: ''{0}''' -f [string]$SourceVMsOriginal.Name)
                    Write-Debug -Message 'if ($ReturnUnmigratableVMs)'
                    if ($ReturnUnmigratableVMs) {
                        Write-Debug -Message '@{SourceVMs = $SourceVMsOriginal, UnmigratableVMs = $UnmigratableVMs}'
                        @{
                            SourceVMs       = $SourceVMsOriginal
                            UnmigratableVMs = $UnmigratableVMs
                        }
                    }
                    else {
                        Write-Debug -Message '@{SourceVMs = $SourceVMsOriginal}'
                        @{
                            SourceVMs = $SourceVMsOriginal
                        }
                    }
                }
                else {
                    Write-Debug -Message 'if ($ReturnUnmigratableVMs)'
                    if ($ReturnUnmigratableVMs) {
                        Write-Debug -Message '$UnmigratableVMs'
                        $UnmigratableVMs
                    }
                }
            }
        }
        else {
            $Message = 'Source ({0}) and destination ({1}) servers are the same' -f $SourceHostName, $DestinationHostName
            $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.ArgumentException' -ArgumentList $Message), 'ArgumentException', [System.Management.Automation.ErrorCategory]::InvalidArgument, $null)))
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