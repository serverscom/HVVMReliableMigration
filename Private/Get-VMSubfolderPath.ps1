function Get-VMSubfolderPath {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$VMName,
        [Parameter(Mandatory)]
        [string]$HostName,
        [Parameter(Mandatory)]
        [string]$Path
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    Write-Debug -Message ('$VMName: ''{0}''' -f $VMName)
    Write-Debug -Message ('$HostName = ''{0}''' -f $HostName)
    Write-Debug -Message ('$Path = ''{0}''' -f $Path)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$NewPath = [System.IO.Path]::Combine(''{0}'', ''{1}'')' -f $Path, $VMName)
        $SubFolderPath = [System.IO.Path]::Combine($Path, $VMName) # Join-Path cannot combine paths on a drive which does not exist on the machine
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
            Write-Debug -Message ('$Folder = Get-FolderCimObject -ComputerName ''{0}'' -Path ''{1}''' -f $HostName, $NewPath)
            $Folder = Get-FolderCimObject -ComputerName $HostName -Path $NewPath
            Write-Debug -Message ('$Folder: ''{0}''' -f $Folder)
            Write-Debug -Message '$Counter++'
            $Counter++
            Write-Debug -Message ('$Counter = {0}' -f $Counter)
        }
        while ($Folder)

        Write-Debug -Message '$NewPath'
        $NewPath

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