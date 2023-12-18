
# Modules

Import-Module (Resolve-Path('.\powershell_modules\authentication.psm1'))
Import-Module (Resolve-Path('.\powershell_modules\UI.psm1'))
Import-Module (Resolve-Path('.\powershell_modules\bluetooth_disable.psm1'))
Import-Module (Resolve-Path('.\powershell_modules\bitlocker_disable.psm1'))
Import-Module (Resolve-Path('.\powershell_modules\language_config.psm1'))

# Installation

# User Authentication:
# Network ID to access to \\tnsafs02.tenaris.techint.net

do {
    [string]$entryPoint = Authentication
    Start-Sleep 2000
}until($entryPoint -eq 'Authentication True')

# If there is no access task sequence does not start
Start-Sleep 2000

do {

    [string]$optionMenuSelected = UI_menu

    # $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path
    # $os = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property Manufacturer 
    switch ($optionMenuSelected) {
        'Config Sequence' {

            Write-Host "Test config sequence"
            Start-Sleep 2000
            # Autenticación de Credenciales
      
            # Folder Shared
            New-Item -Path D:\ -ItemType Directory -Name Shared

            try { Disable-Bluetooth } catch { "Error during Bluetooth Disable Procedure... $($_.Exception.Message)" }
            try { Disable-BitLocker } catch { "Error during BitLocker Disable Procedure... $($_.Exception.Message)" }

            [string]$sourceDirectory = "\\tnsafs02.tenaris.techint.net\Packages\Global Applications\AutoDesk_DWG2020"
            [string]$destionationDirectory = "D:\Shared\"
            Copy-Item -Force -Recurse -Verbose $sourceDirectory -Destination $destinationDirectory

            Set-Location "D:\Shared\AutoDesk_DWG2020"
            try { Start-Process -FilePath "Setup.exe" -ArgumentList "/Q /W /I setup.ini" -Wait } catch { "Error during AutoDesk_DWG2020 Installation Procedure" }

            Set-Location "D:\Shared\"
            Remove-Item -Path "D:\Shared\AutoDesk_DWG2020" -Force -Recurse

            [string]$sourceDirectory = "\\tnsafs02.tenaris.techint.net\Packages\Global Applications\Google_Chrome_x64_105.0.5195.102"
            [string]$destionationDirectory = "D:\Shared\"
            Copy-Item -Force -Recurse -Verbose $sourceDirectory -Destination $destinationDirectory

            Set-Location "D:\Shared\"

            # try { Copy-Item -Path "$PSScriptRoot\03.-Shared\Shared" -Destination D:\ -Recurse -Force } catch { "$($_.Exception.Message)" }
            #            try {
            #                Copy-Item -Path "$PSScriptRoot\01-SWBase\CheckList Gruas.url" -Destination C:\Users\Public\Desktop
            #                Copy-Item -Path "$PSScriptRoot\01-SWBase\Tenaris Shop Floor.url" -Destination C:\Users\Public\Desktop
            #                Copy-Item -Path "$PSScriptRoot\01-SWBase\Nombre Completo de PC.bat" -Destination C:\Users\Public\Desktop
            #                Copy-Item -Path "$PSScriptRoot\01-SWBase\Correo Web On Premise.url" -Destination C:\Users\Public\Desktop
            #                Copy-Item -Path "$PSScriptRoot\01-SWBase\Office Web Cloud.url" -Destination C:\Users\Public\Desktop
            #                Copy-Item -Path "$PSScriptRoot\01-SWBase\Integrated Document Management.lnk" -Destination C:\Users\Public\Desktop
            #            } catch { "$($_.Exception.Message)" }
            #
            #            <# Application Installation Sequence #>
            #            Start-Process "$PSScriptRoot\02-Install\01-Administrador de impresora\admin impresora.bat" -Wait
            #            Start-Process "$PSScriptRoot\02-Install\04-Chrome\ChromeSetup.exe" -Wait
            #            if ($os -like "*Dell Inc.*") {
            #                Start-Process "$PSScriptRoot\02-Install\05-Dell-Command-Update\Dell-Command-Update-Application_714J9_WIN_4.8.0_A00.EXE" -Wait
            #                Start-Sleep -Seconds 10
            #                Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\DellCommandUpdate.exe" -Wait
            #            }
            #            Start-Process "$PSScriptRoot\02-Install\06-SAP Installer\SAPGUi770_SP8_20220921_1358.exe" -Wait
            #
            #            <# Language Configuration Sequence #>
            #            Set-TimeZone -Id "Central Standard Time (Mexico)"
            #            Set-Culture es-MX
            #            Set-Culture -CultureInfo es-MX
            #            Set-WinSystemLocale -SystemLocale es-MX
            #            Set-WinUILanguageOverride -Language es-ES
            #            Set-WinUserLanguageList es-ES -Force
            #            Get-WinHomeLocation
            #            Set-WinHomeLocation -GeoId 166
            #            Get-WinHomeLocation
            #            
            #            Write-Host "Automated Process Finished... It's necesary to restart..."
            #            $input_3 = Read-Host "Restart? [y/n]"
            #            if ($input_3 -eq 'y'){
            #                shutdown -r
            #            }
        }
        'sc_check' {
            Write-Host "Software Center Repair Sequence..."
            do {
                Start-Process 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Endpoint Manager\Configuration Manager\Software Center.lnk' -Wait
                $repairInput = Read-Host "Repair [y/n]"
                if ($repairInput -eq 'y') {
                    Start-Process 'C:\Windows\CCM\ccmrepair.exe' -Wait
                    Start-Process 'C:\Windows\CCM\CcmRestart.exe' -Wait
                    Start-Process "control.exe" -ArgumentList "smscfgrc" -Wait
                }
            } until ($repairInput -eq 'n')
        }
        'exit' {
            Write-Host "
            Exit
            "
            return
        }
    }
    pause
}

until ($optionMenuSelected -eq 'exit')
