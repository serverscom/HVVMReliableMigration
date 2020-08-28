function Test-VMBackingUpStatus {

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param (
        [Parameter(Mandatory)]
        [Microsoft.HyperV.PowerShell.VirtualMachine]$VM,
        [switch]$Force,
        [switch]$PassThru
    )

    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$VM: ''{0}''' -f [string]$VM)
        Write-Debug -Message ('$VM.Name: ''{0}''' -f $VM.Name)
        Write-Debug -Message ('$VM.Id: ''{0}''' -f $VM.Id)
        Write-Debug -Message ('$Force = ${0}' -f $Force)
        Write-Debug -Message ('$PassThru = ${0}' -f $PassThru)

        Write-Debug -Message ('$VMHostName = ''{0}''' -f $VM.ComputerName)
        $VMHostName = $VM.ComputerName
        Write-Debug -Message ('$VMHostName = ''{0}''' -f $VMHostName)

        Write-Debug -Message 'if ($Force)'
        if ($Force) {
            Write-Debug -Message ('$VMItem = Get-VM -ComputerName ''{0}'' -Id ''{1}''' -f $VMHostName, $VM.Id)
            $VMItem = Get-VM -ComputerName $VMHostName -Id $VM.Id
        }
        else {
            Write-Debug -Message '$VMItem = $VM'
            $VMItem = $VM
        }
        Write-Debug -Message ('$VMItem: ''{0}''' -f [string]$VMItem)
        Write-Debug -Message ('$VMItem.Name: ''{0}''' -f $VMItem.Name)
        Write-Debug -Message ('$VMItem.Id: ''{0}''' -f $VMItem.Id)

        Write-Debug -Message '$Result = $false'
        $Result = $false
        Write-Debug -Message ('$Result: ''{0}''' -f $Result)

        Write-Debug -Message ('$VMItem.PrimaryOperationalStatus: ''{0}''' -f $VMItem.PrimaryOperationalStatus)
        Write-Debug -Message ('$VMItem.SecondaryOperationalStatus: ''{0}''' -f $VMItem.SecondaryOperationalStatus)
        Write-Debug -Message ('$VMItem.State: ''{0}''' -f $VMItem.State)
        Write-Debug -Message 'if ($VMItem.PrimaryOperationalStatus -eq [Microsoft.HyperV.PowerShell.VMOperationalStatus]::InService)'
        if ($VMItem.PrimaryOperationalStatus -eq [Microsoft.HyperV.PowerShell.VMOperationalStatus]::InService) {
            Write-Debug -Message 'if ($VMItem.PrimaryOperationalStatus -eq [Microsoft.HyperV.PowerShell.VMOperationalStatus]::BackingUpVirtualMachine -or $null -eq $VMItem.SecondaryOperationalStatus)'
            if ($VMItem.SecondaryOperationalStatus -eq [Microsoft.HyperV.PowerShell.VMOperationalStatus]::BackingUpVirtualMachine -or $null -eq $VMItem.SecondaryOperationalStatus) {
                Write-Debug -Message '$Result = $true'
                $Result = $true
            }
        }
        Write-Debug -Message ('$Result: ''{0}''' -f $Result)
        Write-Debug -Message '$Result'
        $Result

        Write-Debug -Message ('$PassThru: ''{0}''' -f $PassThru)
        Write-Debug -Message 'if ($PassThru)'
        if ($PassThru) {
            Write-Debug -Message '$VMItem'
            $VMItem
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