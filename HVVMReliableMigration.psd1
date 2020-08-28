@{
    RootModule         = 'HVVMReliableMigration.psm1'
    ModuleVersion      = '1.0.0'
    GUID               = '901d64bc-c223-4546-9040-c697334fca4b'
    Author             = 'Kirill Nikolaev'
    CompanyName        = 'Fozzy Inc.'
    Copyright          = '(c) 2020 Fozzy Inc. All rights reserved.'
    PowerShellVersion  = '5.1'
    Description        = 'Solves 2 problems which you most certainly bump into, when migrating VMs in a shared-nothing Hyper-V environment.'
    RequiredModules    = @(
        'Hyper-V'
        'ThreadJob'
    )
    RequiredAssemblies = @(
        'Microsoft.HyperV.PowerShell.Objects' # https://social.technet.microsoft.com/Forums/windowsserver/en-US/855849cf-fffd-419f-ad8b-1be47b5d847b/powershell-type-conversion-problems?forum=winserverpowershell
    )
    FunctionsToExport  = @(
        'Move-VMReliably'
    )
    CmdletsToExport    = @()
    AliasesToExport    = @()
    PrivateData        = @{
        PSData = @{
            Tags                       = @()
            LicenseUri                 = 'https://github.com/FozzyHosting/HVVMReliableMigration/blob/master/LICENSE'
            ProjectUri                 = 'https://github.com/FozzyHosting/HVVMReliableMigration/'
            ReleaseNotes               = ''
            ExternalModuleDependencies = @(
                'Hyper-V'
                'ThreadJob'
            )
        }
    }
}