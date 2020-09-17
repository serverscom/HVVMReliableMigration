function Remove-EmptyVMFolder {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [System.Collections.Hashtable]$ResourceMapping
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$ResourceMapping: ''{0}''' -f ($ResourceMapping | Out-String))

        Write-Debug -Message '$ComputerName = $ResourceMapping.HostName'
        $ComputerName = $ResourceMapping.HostName
        Write-Debug -Message ('$ComputerName = ''{0}''' -f $ComputerName)
        Write-Debug -Message '$VMConfigPath = $ResourceMapping.ConfigPath'
        $VMConfigPath = $ResourceMapping.ConfigPath
        Write-Debug -Message ('$VMConfigPath = ''{0}''' -f $VMConfigPath)
        Write-Debug -Message '$VMPath = $ResourceMapping.VMPath'
        $VMPath = $ResourceMapping.VMPath
        Write-Debug -Message ('$VMPath = ''{0}''' -f $VMPath)
        Write-Debug -Message '$VMPathID = $ResourceMapping.VMPathID'
        $VMPathID = $ResourceMapping.VMPathID
        Write-Debug -Message ('$VMPathID = ''{0}''' -f $VMPathID)
        Write-Debug -Message '$SmartPagingFilePath = $ResourceMapping.SmartPagingFilePath'
        $SmartPagingFilePath = $ResourceMapping.SmartPagingFilePath
        Write-Debug -Message ('$SmartPagingFilePath = ''{0}''' -f $SmartPagingFilePath)
        Write-Debug -Message '$SmartPagingFilePathID = $ResourceMapping.SmartPagingFilePathID'
        $SmartPagingFilePathID = $ResourceMapping.SmartPagingFilePathID
        Write-Debug -Message ('$SmartPagingFilePathID = ''{0}''' -f $SmartPagingFilePathID)
        Write-Debug -Message '$VMOtherPaths = $ResourceMapping.OtherPaths'
        $VMOtherPaths = $ResourceMapping.OtherPaths
        Write-Debug -Message ('$VMOtherPaths: ''{0}''' -f [string]$VMOtherPaths)

        Write-Debug -Message ('Remove-EmptyFolder -Path ''{0}'' -ComputerName ''{1}'' -KeepFirstLevelFolder' -f $SmartPagingFilePathID, $ComputerName)
        Remove-EmptyFolder -Path $SmartPagingFilePathID -ComputerName $ComputerName -KeepFirstLevelFolder
        Write-Debug -Message ('Remove-EmptyFolder -Path ''{0}'' -ComputerName ''{1}'' -RemoveParentFolder -KeepFirstLevelFolder' -f $SmartPagingFilePath, $ComputerName)
        Remove-EmptyFolder -Path $SmartPagingFilePath -ComputerName $ComputerName -RemoveParentFolder -KeepFirstLevelFolder

        Write-Debug -Message ('Remove-EmptyFolder -Path ''{0}'' -ComputerName ''{1}'' -KeepFirstLevelFolder' -f $VMPathID, $ComputerName)
        Remove-EmptyFolder -Path $VMPathID -ComputerName $ComputerName -KeepFirstLevelFolder
        Write-Debug -Message ('Remove-EmptyFolder -Path ''{0}'' -ComputerName ''{1}'' -RemoveParentFolder -KeepFirstLevelFolder' -f $VMPath, $ComputerName)
        Remove-EmptyFolder -Path $VMPath -ComputerName $ComputerName -RemoveParentFolder -KeepFirstLevelFolder

        foreach ($FolderPath in $VMOtherPaths) {
            Write-Debug -Message ('Remove-EmptyFolder -Path ''{0}'' -ComputerName ''{1}'' -RemoveParentFolder -KeepFirstLevelFolder' -f $FolderPath, $ComputerName)
            Remove-EmptyFolder -Path $FolderPath -ComputerName $ComputerName -RemoveParentFolder -KeepFirstLevelFolder
        }

        Write-Debug -Message ('Remove-EmptyFolder -Path ''{0}'' -ComputerName ''{1}'' -RemoveParentFolder -KeepFirstLevelFolder' -f $VMConfigPath, $ComputerName)
        Remove-EmptyFolder -Path $VMConfigPath -ComputerName $ComputerName -RemoveParentFolder -KeepFirstLevelFolder

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