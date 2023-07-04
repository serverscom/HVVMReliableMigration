function Get-CustomDestinationVHDPaths {

    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName = 'PutInASubfolder', Mandatory)]
        [string]$VMName,
        [Parameter(ParameterSetName = 'Common', Mandatory)]
        [Parameter(ParameterSetName = 'PutInASubfolder', Mandatory)]
        [string[]]$SourceVMVHDPaths,
        [Parameter(ParameterSetName = 'Common', Mandatory)]
        [Parameter(ParameterSetName = 'PutInASubfolder', Mandatory)]
        [string]$DestinationHostName,
        [Parameter(ParameterSetName = 'Common', Mandatory)]
        [Parameter(ParameterSetName = 'PutInASubfolder', Mandatory)]
        [string]$DestinationPath,
        [Parameter(ParameterSetName = 'Common')]
        [Parameter(ParameterSetName = 'PutInASubfolder')]
        [switch]$PutInASubfolder
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {

        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$VMName = ''{0}''' -f $VMName)
        Write-Debug -Message ('$SourceVMVHDPaths: ''{0}''' -f [string]$SourceVMVHDPaths)
        Write-Debug -Message ('$DestinationHostName = ''{0}''' -f $DestinationHostName)
        Write-Debug -Message ('$DestinationPath = ''{0}''' -f $DestinationPath)
        Write-Debug -Message ('$PutInASubfolder = ${0}' -f $PutInASubfolder)

        Write-Debug -Message 'if ($SourceVMVHDPaths.Count -gt 1)'
        if ($SourceVMVHDPaths.Count -gt 1) {
            Write-Debug -Message ('${0}' -f [string]($SourceVMVHDPaths.Count -gt 1))

            Write-Debug -Message '$SourcePathsQualifiersUniqueCount = (Split-Path -Path $SourceVMVHDPaths -Qualifier | Select-Object -Unique).Count'
            $SourcePathsQualifiersUniqueCount = (Split-Path -Path $SourceVMVHDPaths -Qualifier | Select-Object -Unique).Count
            Write-Debug -Message ('$SourcePathsQualifiersUniqueCount = {0}' -f $SourcePathsQualifiersUniqueCount)

            Write-Debug -Message 'if ($SourcePathsQualifiersUniqueCount -gt 1)'
            if ($SourcePathsQualifiersUniqueCount -gt 1) {
                Write-Debug -Message ('${0}' -f [string]($SourcePathsQualifiersUniqueCount -gt 1))

                Write-Debug -Message ('$DestinationPathQualifier = Split-Path -Qualifier -Path ''{0}''' -f $DestinationPath)
                $DestinationPathQualifier = Split-Path -Qualifier -Path $DestinationPath
                Write-Debug -Message ('$DestinationPathQualifier = ''{0}''' -f $DestinationPathQualifier)
                Write-Debug -Message ('$DestinationPathWithoutQualifier = Split-Path -NoQualifier -Path ''{0}''' -f $DestinationPath)
                $DestinationPathWithoutQualifier = Split-Path -NoQualifier -Path $DestinationPath
                Write-Debug -Message ('$DestinationPathWithoutQualifier = ''{0}''' -f $DestinationPathWithoutQualifier)
                Write-Debug -Message ('$DestinationPathWithoutQualifierTrimmed = ''{0}''.TrimStart(''{1}'')' -f $DestinationPathWithoutQualifier, [System.IO.Path]::DirectorySeparatorChar)
                $DestinationPathWithoutQualifierTrimmed = $DestinationPathWithoutQualifier.TrimStart([System.IO.Path]::DirectorySeparatorChar)
                Write-Debug -Message ('$DestinationPathWithoutQualifierTrimmed = ''{0}''' -f $DestinationPathWithoutQualifierTrimmed)

                Write-Debug -Message 'foreach ($SourceVMVHDPath in $SourceVMVHDPaths)'
                foreach ($SourceVMVHDPath in $SourceVMVHDPaths) {
                    Write-Debug -Message ('$SourceVMVHDPath = ''{0}''' -f $SourceVMVHDPath)

                    Write-Debug -Message ('$VHDName = Split-Path -Path ''{0}'' -Leaf' -f $SourceVMVHDPath)
                    $VHDName = Split-Path -Path $SourceVMVHDPath -Leaf
                    Write-Debug -Message ('$VHDName = ''{0}''' -f $VHDName)
                    Write-Debug -Message ('$SourceVHDPathQualifier = Split-Path -Path ''{0}'' -Qualifier' -f $SourceVMVHDPath)
                    $SourceVHDPathQualifier = Split-Path -Path $SourceVMVHDPath -Qualifier
                    Write-Debug -Message ('$SourceVHDPathQualifier = ''{0}''' -f $SourceVHDPathQualifier)

                    Write-Debug -Message 'if ($SourceVHDPathQualifier -eq $DestinationPathQualifier)'
                    if ($SourceVHDPathQualifier -eq $DestinationPathQualifier) {
                        Write-Debug -Message ('${0}' -f [string]($SourceVHDPathQualifier -eq $DestinationPathQualifier))
                        Write-Debug -Message 'if ($PutInASubfolder)'
                        if ($PutInASubfolder) {
                            Write-Debug -Message ('${0}' -f [string]$PutInASubfolder)

                            Write-Debug -Message ('$DestinationVHDFolder = Get-VMSubfolderPath -VMName ''{0}'' -HostName ''{1}'' -Path ''{2}''' -f $VMName, $DestinationHostName, $DestinationPath)
                            $DestinationVHDFolder = Get-VMSubfolderPath -VMName $VMName -HostName $DestinationHostName -Path $DestinationPath
                        }
                        else {
                            Write-Debug -Message ('${0}' -f [string]$PutInASubfolder)

                            Write-Debug -Message ('$DestinationVHDFolder = ''{0}''' -f $DestinationPath)
                            $DestinationVHDFolder = $DestinationPath
                        }
                        Write-Debug -Message ('$DestinationVHDFolder = ''{0}''' -f $DestinationVHDFolder)

                    }
                    else {
                        Write-Debug -Message ('${0}' -f [string]($SourceVHDPathQualifier -eq $DestinationPathQualifier))
                        Write-Debug -Message ('$DestinationDrive = (''{{0}}{{1}}'' -f ''{0}'', ''{1}'')' -f $SourceVHDPathQualifier, [System.IO.Path]::DirectorySeparatorChar)
                        $DestinationDrive = ('{0}{1}' -f $SourceVHDPathQualifier, [System.IO.Path]::DirectorySeparatorChar)
                        Write-Debug -Message ('$DestinationDrive = ''{0}''' -f $DestinationDrive)
                        Write-Debug -Message ('$DestinationMigrationPath = [IO.Path]::Combine(''{0}'', ''{1}'')' -f $DestinationDrive, $DestinationPathWithoutQualifierTrimmed)
                        $DestinationMigrationPath = [IO.Path]::Combine($DestinationDrive, $DestinationPathWithoutQualifierTrimmed)
                        Write-Debug -Message ('$DestinationMigrationPath = ''{0}''' -f $DestinationMigrationPath)
                        Write-Debug -Message ('$DestinationMigrationPathCimObject = Get-FolderCimObject -ComputerName ''{0}'' -Path ''{1}''' -f $DestinationHostName, $DestinationMigrationPath)
                        $DestinationMigrationPathCimObject = Get-FolderCimObject -ComputerName $DestinationHostName -Path $DestinationMigrationPath
                        Write-Debug -Message ('$DestinationMigrationPathCimObject: ''{0}''' -f [string]$DestinationMigrationPathCimObject)

                        Write-Debug -Message 'if (-not $DestinationMigrationPathCimObject)'
                        if (-not $DestinationMigrationPathCimObject) {
                            Write-Debug -Message ('${0}' -f [string](-not $DestinationMigrationPathCimObject))

                            $Message = 'The destination path ''{0}'' is not exist or unavailable.' -f $DestinationMigrationPath
                            $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.Management.Automation.ItemNotFoundException' -ArgumentList $Message), 'ItemNotFoundException', [System.Management.Automation.ErrorCategory]::ObjectNotFound, $null)))
                        }
                        else {
                            Write-Debug -Message ('${0}' -f [string](-not $DestinationMigrationPathCimObject))
                        }

                        Write-Debug -Message 'if ($PutInASubfolder)'
                        if ($PutInASubfolder) {
                            Write-Debug -Message ('${0}' -f [string]$PutInASubfolder)
                            Write-Debug -Message ('$DestinationVHDFolder = Get-VMSubfolderPath -VMName ''{0}'' -HostName ''{1}'' -Path ''{2}''' -f $VMName, $DestinationHostName, $DestinationMigrationPath)
                            $DestinationVHDFolder = Get-VMSubfolderPath -VMName $VMName -HostName $DestinationHostName -Path $DestinationMigrationPath
                            Write-Debug -Message ('$DestinationVHDFolder = ''{0}''' -f $DestinationVHDFolder)
                        }
                        else {
                            Write-Debug -Message ('${0}' -f [string]$PutInASubfolder)
                            Write-Debug -Message ('$DestinationVHDFolder = ''{0}''' -f $DestinationMigrationPath)
                            $DestinationVHDFolder = $DestinationMigrationPath
                            Write-Debug -Message ('$DestinationVHDFolder = ''{0}''' -f $DestinationVHDFolder)
                        }

                    }

                    Write-Debug -Message ('$DestinationVHDPath = [IO.Path]::Combine(''{0}'', ''{1}''' -f $DestinationVHDFolder, $VHDName)
                    $DestinationVHDPath = [IO.Path]::Combine($DestinationVHDFolder, $VHDName)
                    Write-Debug -Message ('$DestinationVHDPath = ''{0}''' -f $DestinationVHDPath)

                    Write-Debug -Message "
                        @{
                            ''SourceFilePath''      = $SourceVMVHDPath
                            ''DestinationFilePath'' = $DestinationVHDPath
                        }
                    "

                    @{
                        'SourceFilePath'      = $SourceVMVHDPath
                        'DestinationFilePath' = $DestinationVHDPath
                    }

                }
            }
            else {
                Write-Debug -Message ('${0}' -f [string]($SourcePathsQualifiersUniqueCount -gt 1))
            }
        }
        else {
            Write-Debug -Message ('${0}' -f [string]($SourceVMVHDPaths.Count -gt 1))
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
