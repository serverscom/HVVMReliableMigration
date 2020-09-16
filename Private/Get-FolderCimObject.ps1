function Get-FolderCimObject {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [Parameter(Mandatory)]
        [string]$Path
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$Path = ''{0}''' -f $Path)

        Write-Debug -Message ('[System.IO.Path]::DirectorySeparatorChar: ''{0}''' -f [System.IO.Path]::DirectorySeparatorChar)
        Write-Debug -Message 'if ($Path.EndsWith([System.IO.Path]::DirectorySeparatorChar))'
        if ($Path.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
            Write-Debug -Message '$Path = $Path.TrimEnd([System.IO.Path]::DirectorySeparatorChar)'
            $Path = $Path.TrimEnd([System.IO.Path]::DirectorySeparatorChar)
        }
        Write-Debug -Message ('$Path = ''{0}''' -f $Path)

        Write-Debug -Message ('$FilterPath = [RegEx]::Replace(''{0}'', ''\\'', ''\\'')' -f $Path)
        $FilterPath = [RegEx]::Replace($Path, '\\', '\\')
        Write-Debug -Message ('$FilterPath = ''{0}''' -f $FilterPath)

        Write-Debug -Message ('Get-CimInstance -ComputerName ''{0}'' -ClassName ''Win32_Directory'' -Filter (''Name = ''''{{0}}'''''' -f ''{1}'')' -f $ComputerName, $FilterPath)
        Get-CimInstance -ComputerName $ComputerName -ClassName 'Win32_Directory' -Filter ('Name = ''{0}''' -f $FilterPath)

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