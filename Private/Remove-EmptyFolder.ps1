function Remove-EmptyFolder {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [Parameter(Mandatory)]
        [string]$Path,
        [switch]$RemoveParentFolder,
        [switch]$KeepFirstLevelFolder
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message ('$Path = ''{0}''' -f $Path)
        Write-Debug -Message ('$RemoveParentFolder = ${0}' -f $RemoveParentFolder)
        Write-Debug -Message ('$KeepFirstLevelFolder = ${0}' -f $KeepFirstLevelFolder)

        Write-Debug -Message '$Proceed = $false'
        $Proceed = $false
        Write-Debug -Message ('$Proceed = ${0}' -f $Proceed)
        Write-Debug -Message 'if ($KeepFirstLevelFolder)'
        if ($KeepFirstLevelFolder) {
            $PathQualifier = Split-Path -Path $Path -Qualifier
            Write-Debug -Message ('$VolumeRootDirectoryPath = ''{{0}}{{1}}'' -f ''{0}'', ''{1}''' -f $PathQualifier, [System.IO.Path]::DirectorySeparatorChar)
            $VolumeRootDirectoryPath = '{0}{1}' -f $PathQualifier, [System.IO.Path]::DirectorySeparatorChar
            Write-Debug -Message ('$VolumeRootDirectoryPath = ''{0}''' -f $VolumeRootDirectoryPath)
            Write-Debug -Message ('$ParentFolderPath = Split-Path -Path ''{0}''' -f $Path)
            $ParentFolderPath = Split-Path -Path $Path
            Write-Debug -Message ('$ParentFolderPath = ''{0}''' -f $ParentFolderPath)
            Write-Debug -Message 'if ($ParentFolderPath -ne $VolumeRootDirectoryPath)'
            if ($ParentFolderPath -ne $VolumeRootDirectoryPath) {
                Write-Debug -Message '$Proceed = $true'
                $Proceed = $true
            }
        }
        else {
            Write-Debug -Message '$Proceed = $true'
            $Proceed = $true
        }
        Write-Debug -Message ('$Proceed = ${0}' -f $Proceed)

        Write-Debug -Message 'if ($Proceed)'
        if ($Proceed) {
            Write-Debug -Message ('[System.IO.Path]::DirectorySeparatorChar: ''{0}''' -f [System.IO.Path]::DirectorySeparatorChar)
            Write-Debug -Message 'if ($Path.EndsWith([System.IO.Path]::DirectorySeparatorChar))'
            if ($Path.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
                Write-Debug -Message '$Path = $Path.TrimEnd([System.IO.Path]::DirectorySeparatorChar)'
                $Path = $Path.TrimEnd([System.IO.Path]::DirectorySeparatorChar)
            }
            Write-Debug -Message ('$Path = ''{0}''' -f $Path)

            Write-Debug -Message ('$Folder = Get-FolderCimObject -ComputerName ''{0}'' -Path ''{1}''' -f $ComputerName, $Path)
            $Folder = Get-FolderCimObject -ComputerName $ComputerName -Path $Path
            Write-Debug -Message ('$Folder: ''{0}''' -f $Folder)

            Write-Debug -Message 'if ($Folder)'
            if ($Folder) {
                Write-Debug -Message ('$Query = ''ASSOCIATORS OF {{{{Win32_Directory.Name=''''{{0}}''''}}}} WHERE AssocClass = Win32_Subdirectory ResultRole = PartComponent'' -f ''{0}''' -f $Path)
                $Query = 'ASSOCIATORS OF {{Win32_Directory.Name=''{0}''}} WHERE AssocClass = Win32_Subdirectory ResultRole = PartComponent' -f $Path
                Write-Debug -Message ('$Query = ''{0}''' -f $Query)
                Write-Debug -Message ('$Subfolders = Get-CimInstance -ComputerName ''{0}'' -Query ''{1}''' -f $ComputerName, $Query)
                $Subfolders = Get-CimInstance -ComputerName $ComputerName -Query $Query
                Write-Debug -Message ('$Subfolders: ''{0}''' -f [string]$Subfolders)

                Write-Debug -Message 'if (-not $Subfolders)'
                if (-not $Subfolders) {
                    Write-Debug -Message ('$Path = ''{0}''' -f $Path)
                    Write-Debug -Message ('[System.IO.Path]::DirectorySeparatorChar: ''{0}''' -f [System.IO.Path]::DirectorySeparatorChar)
                    Write-Debug -Message '-not if ($Path.EndsWith([System.IO.Path]::DirectorySeparatorChar))'
                    if (-not $Path.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
                        Write-Debug -Message '$Path = $Path.TrimEnd([System.IO.Path]::DirectorySeparatorChar)'
                        $Path = '{0}{1}' -f $Path, [System.IO.Path]::DirectorySeparatorChar
                    }
                    Write-Debug -Message ('$Path = ''{0}''' -f $Path)

                    Write-Debug -Message ('$FilterPath = [RegEx]::Replace(''{0}'', ''\\'', ''\\'')' -f $Path)
                    $FilterPath = [RegEx]::Replace($Path, '\\', '\\')
                    Write-Debug -Message ('$FilterPath = ''{0}''' -f $FilterPath)

                    Write-Debug -Message ('$Query = ''SELECT * FROM CIM_DataFile WHERE Path = ''''{{0}}'''''' -f ''{0}''' -f $FilterPath)
                    $Query = 'SELECT * FROM CIM_DataFile WHERE Path = ''{0}''' -f $FilterPath
                    Write-Debug -Message ('$Query = ''{0}''' -f $Query)
                    Write-Debug -Message ('$Files = Get-CimInstance -ComputerName ''{0}'' -Query ''{1}''' -f $ComputerName, $Query)
                    $Files = Get-CimInstance -ComputerName $ComputerName -Query $Query
                    Write-Debug -Message ('$Files: ''{0}''' -f [string]$Files)

                    Write-Debug -Message 'if (-not $Files)'
                    if (-not $Files) {
                        Write-Debug -Message '$null = Invoke-CimMethod -InputObject $Folder -MethodName ''Delete'''
                        $null = Invoke-CimMethod -InputObject $Folder -MethodName 'Delete'

                        Write-Debug -Message ('$RemoveParentFolder = ${0}' -f $RemoveParentFolder)
                        Write-Debug -Message 'if ($RemoveParentFolder)'
                        if ($RemoveParentFolder) {
                            Write-Debug -Message ('$ParentFolderPath = Split-Path -Path ''{0}''' -f $Path)
                            $ParentFolderPath = Split-Path -Path $Path
                            Write-Debug -Message ('$ParentFolderPath = ''{0}''' -f $ParentFolderPath)

                            Write-Debug -Message ('Remove-EmptyFolder -ComputerName ''{0}'' -Path ''{1}'' -KeepFirstLevelFolder:${2}' -f $ComputerName, $ParentFolderPath, $KeepFirstLevelFolder)
                            Remove-EmptyFolder -ComputerName $ComputerName -Path $ParentFolderPath -KeepFirstLevelFolder:$KeepFirstLevelFolder
                        }
                    }
                }
            }
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