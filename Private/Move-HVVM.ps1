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

        Write-Debug -Message 'if ($PutInASubfolder)'
        if ($PutInASubfolder) {
            Write-Debug -Message ('$NewPath = [System.IO.Path]::Combine(''{0}'', ''{1}'')' -f $Path, $VM.Name)
            $SubFolderPath = [System.IO.Path]::Combine($Path, $VM.Name) # Join-Path cannot combine paths on a drive which does not exist on the machine
            Write-Debug -Message ('$SubFolderPath = ''{0}''' -f $SubFolderPath)

            Write-Debug -Message '$NewPath = $SubFolderPath'
            $NewPath = $SubFolderPath
            Write-Debug -Message ('$NewPath = ''{0}''' -f $NewPath)

            Write-Debug -Message '$Counter = 0'
            $Counter = 0
            Write-Debug -Message ('$Counter = {0}' -f $Counter)
            do {
                if ($Counter -gt 0) {
                    Write-Debug -Message ('$NewPath = ''{{0}}-{{1}}'' -f ''{0}'',''{1}''' -f $SubFolderPath, $Counter)
                    $NewPath = '{0}-{1}' -f $SubFolderPath, $Counter
                    Write-Debug -Message ('$NewPath = ''{0}''' -f $NewPath)
                }
                Write-Debug -Message ('$FilterPath = [RegEx]::Replace(''{0}'', ''\\'', ''\\'')' -f $NewPath)
                $FilterPath = [RegEx]::Replace($NewPath, '\\', '\\')
                Write-Debug -Message ('$FilterPath = ''{0}''' -f $FilterPath)
                Write-Debug -Message ('$Folder = Get-CimInstance -ComputerName ''{0}'' -ClassName ''Win32_Directory'' -Filter (''Name = ''''{{0}}'''''' -f ''{1}'')' -f $HostName, $FilterPath)
                $Folder = Get-CimInstance -ComputerName $HostName -ClassName 'Win32_Directory' -Filter ('Name = ''{0}''' -f $FilterPath)
                Write-Debug -Message ('$Folder: ''{0}''' -f $Folder)
                Write-Debug -Message '$Counter++'
                $Counter++
                Write-Debug -Message ('$Counter = {0}' -f $Counter)
            }
            while ($Folder)

            Write-Debug -Message '$Path = $NewPath'
            $Path = $NewPath
            Write-Debug -Message ('$Path = ''{0}''' -f $Path)
        }

        Write-Debug -Message ('$null = Move-VM -VM $VM -DestinationHost ''{0}'' -IncludeStorage -DestinationStoragePath ''{1}''' -f $HostName, $Path)
        $null = Move-VM -VM $VM -DestinationHost $HostName -IncludeStorage -DestinationStoragePath $Path

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