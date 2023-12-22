
# Relative Path
$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Modules
Import-Module $rootPath\.\powershell_modules\authentication.psm1
Import-Module $rootPath\.\powershell_modules\UI.psm1
Import-Module $rootPath\.\powershell_modules\bluetooth_disable.psm1
Import-Module $rootPath\.\powershell_modules\bitlocker_disable.psm1
Import-Module $rootPath\.\powershell_modules\language_config.psm1

# Installation
[string]$entryPoint
do {
    $entryPoint = Authentication
}until($entryPoint -eq 'Authentication True')
# If there is no access task sequence does not start

do {
    [string]$optionMenuSelected = UI_menu
    $os = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property Manufacturer
    switch ($optionMenuSelected) {
        'Config Sequence' {
            # Folder Shared
            if (-not (Test-Path "D:\Shared\")) { New-Item -Path D:\ -ItemType Directory -Name Shared }
            try { Disable-Bluetooth } catch { "Error during Bluetooth Disable Procedure... $($_.Exception.Message)" }
            try { Disable-VolumeBitLocker } catch { "Error during BitLocker Disable Procedure... $($_.Exception.Message)" }
            try {
                Copy-Item -Path "$rootPath\shortcuts\CheckList Gruas.url" -Destination C:\Users\Public\Desktop
                Copy-Item -Path "$rootPath\shortcuts\Tenaris Shop Floor.url" -Destination C:\Users\Public\Desktop
                Copy-Item -Path "$rootPath\shortcuts\Nombre Completo de PC.bat" -Destination C:\Users\Public\Desktop
                Copy-Item -Path "$rootPath\shortcuts\Correo Web On Premise.url" -Destination C:\Users\Public\Desktop
                Copy-Item -Path "$rootPath\shortcuts\Office Web Cloud.url" -Destination C:\Users\Public\Desktop
                Copy-Item -Path "$rootPath\shortcuts\Integrated Document Management.lnk" -Destination C:\Users\Public\Desktop
            }
            catch { "$($_.Exception.Message)" }
            
            <# Application Installation Sequence #>
            try { 
                Write-Host "Printer Admin Adminstrator Procedure Started..."
                New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name RestrictDriverInstallationToAdministrators -Value 0 -PropertyType DWORD -Force 
            } catch { "Error during Printer Admin Administrator Installation Procedure" }
            
            try {
                Write-Host "AutoDesk Installation Procedure Started..."
                Start-Process -FilePath "$rootPath\..\installation_folder\03-AutoDesk_DWG2021\Setup.exe" -ArgumentList "/Q /W /I setup.ini" -Wait 
            } catch { "Error during AutoDesk_DWG2020 Installation Procedure" }
            try {
                Write-Host "Google Chrome Installation Procedure Started..."
                Start-Process -FilePath "$rootPath\..\installation_folder\04-Chrome\GoogleChromeStandaloneEnterprise64.msi" -ArgumentList 'msiexec /i "GoogleChromeStandaloneEnteprise64.msi /q"' -Wait 
            } catch { "Error during Google Chrome Installation Procedure" }
            try { 
                Write-Host "SAP (SP8) Installation Procedure Procedure Started..."
                Start-Process -FilePath "$rootPath\..\installation_folder\06-SAP Installer\SAPGUi770_SP8_20220921_1358.exe" -ArgumentList "SAPGUi770_SP8_20220921_1358.exe /Silent" -Wait 
            } catch { "Error during SAP (SP8) Installation Procedure" }
            
            <# Language Configuration Sequence #>
            Set-TimeZone -Id "Central Standard Time (Mexico)"
            Set-Culture es-MX
            Set-Culture -CultureInfo es-MX
            Set-WinSystemLocale -SystemLocale es-MX
            Set-WinUILanguageOverride -Language es-ES
            Set-WinUserLanguageList es-ES -Force
            Get-WinHomeLocation
            Set-WinHomeLocation -GeoId 166
            Get-WinHomeLocation
            
            if ($os -like "*Dell Inc.*") {
                try { Start-Process -FilePath "$rootPath\..\installation_folder\05-Dell-Command-Update\Dell-Command-Update-Application_44TH5_WIN_5.1.0_A00.EXE" -ArgumentList "Dell-Command-Update-Application_44TH5_WIN_5.1.0_A00.EXE /factoryinstall /s" -Wait } catch { "Error during Dell Command Update Installation Procedure" }
                Start-Sleep 120
                Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\DellCommandUpdate.exe" -Wait
            }
            
            Write-Host "Automated Process Finished... It's necesary to restart..."
            $restart_input = Read-Host "Restart? [y/n]"
            if ($restart_input -eq 'y') {
                shutdown -r
            }
        }
        'Software Center Check' {
            Write-Host "Software Center Repair Sequence..."
            do {
                Start-Process 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Configuration Manager\Configuration Manager\Software Center.lnk' -Wait
                $repairInput = Read-Host "Repair [y/n]"
                if ($repairInput -eq 'y') {
                    Start-Process 'C:\Windows\CCM\ccmrepair.exe' -Wait
                    Start-Process 'C:\Windows\CCM\CcmRestart.exe' -Wait
                    Start-Process "control.exe" -ArgumentList "smscfgrc" -Wait
                }
            } until ($repairInput -eq 'n')
        }
        'Comprobar Instaladores' {
            if (-not (Test-Path "$rootPath\..\installation_folder\")) {
                New-Item -Path "$rootPath\..\" -ItemType Directory -Name installation_folder

                #[string]$sourceDirectory = "\\tnsafs02.tenaris.techint.net\Packages\Global Applications\AutoDesk_DWG2020"
                #[string]$destinationDirectory = "D:\Shared\"

                # Verbose retired 
                #Copy-Item -Force -Recurse <# -Verbose #> $sourceDirectory -Destination $destinationDirectory

                #Set-Location "D:\Shared\AutoDesk_DWG2020"
                #try { Start-Process -FilePath "Setup.exe" -ArgumentList "/Q /W /I setup.ini" -Wait } catch { "Error during AutoDesk_DWG2020 Installation Procedure" }

                #Set-Location "D:\Shared\"
                #Remove-Item -Path "D:\Shared\AutoDesk_DWG2020" -Force -Recurse

                #[string]$sourceDirectory = "\\tnsafs02.tenaris.techint.net\Packages\Global Applications\Google_Chrome_x64_105.0.5195.102"
                #[string]$destionationDirectory = "D:\Shared\"
                #Copy-Item -Force -Recurse -Verbose $sourceDirectory -Destination $destinationDirectory

                #Set-Location "D:\Shared\"
                #try { Start-Process -FilePath "Setup.exe" -ArgumentList "/Q /W /I setup.ini" -Wait } catch { "Error during AutoDesk_DWG2020 Installation Procedure" }
            }
        }
        'exit' {
            Write-Host "Exit"
            return
        }
    }
}

until ($optionMenuSelected -eq 'exit')
