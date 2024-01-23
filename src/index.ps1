
# Relative Path
$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Modules
# Import-Module $rootPath\.\powershell_modules\authentication.psm1                  # Módulo de autenticación tnsafs02.tenaris.techint.net (inactivo)
Import-Module $rootPath\.\powershell_modules\UI.psm1                                # Módulo de UI
# Import-Module $rootPath\.\powershell_modules\bluetooth_disable.psm1               # Módulo de Bluetooth [Adaptando a Bug PnpDevice (inactivo)]
Import-Module $rootPath\.\powershell_modules\bitlocker_disable.psm1                 # Módulo de inactivación de BitLocker
Import-Module $rootPath\.\powershell_modules\language_config.psm1                   # Configuraciones de idioma

# Installation
#[string]$entryPoint
#do {
#    $entryPoint = Authentication
#}until($entryPoint -eq 'Authentication True')
## If there is no access task sequence does not start

do {
    # Selección de secuencia:
    #   1. Config Sequence
    #   2. Software Center Repair Sequence
    #   3. Comprobar Instaladores
    #   4. Exit
    [string]$optionMenuSelected = UI_menu

    #   Detección de Objecto Manufacturer (Detección de Laptop DELL, HP, ASUS, etc...)
    $os = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property Manufacturer

    switch ($optionMenuSelected) {
        'Config Sequence' {
            # Creación de folder "Shared", si no existe se crea en la ruta E:\
            if (-not (Test-Path "D:\Shared\")) { New-Item -Path D:\ -ItemType Directory -Name Shared }

            # Desactivación de Bluetooth (Inactivo - PnpDevice Bug)
            # try { Disable-Bluetooth } catch { "Error during Bluetooth Disable Procedure... $($_.Exception.Message)" }
            
            # Desactivación de BitLocker, si está inactivo salta la secuencia si no lo desactiva [Módulo a readaptar]
            try { Disable-VolumeBitLocker } catch { "Error during BitLocker Disable Procedure... $($_.Exception.Message)" }
            
            # Creación de accesos directos en directorio "Desktop"
            #   [Readaptación pendiente]
            #
            #
            #   [{000214A0-0000-0000-C000-000000000046}]
            #   Prop3=19,2
            #   [InternetShortcut]
            #   IDList=
            #   URL=https//goog...
            try {
                # Copiar elemento de ruta ./shortcuts/ a C:/Users/Public/Desktop/
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
                # Agregar Printer Admin Administrator a registro (impresora.bat file upgrade)
                #
                # Bug: a3-22 [fixed]
                # Bug: b2 [fixed]
                # Bug: b9 [fixed]
                # Bug: b14 [retired]
                # Bug: c1 [fixed] [final]
                Write-Host "Printer Admin Adminstrator Procedure Started..."
                New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name RestrictDriverInstallationToAdministrators -Value 0 -PropertyType DWORD -Force 
            } catch { "Error during Printer Admin Administrator Installation Procedure" }
            

            # Start-Process: Ejecuta un programa .exe .msi u otra extensión de OS
            # -FilePath: Moverse en una dirección específica, en este caso busca dentro de una carpeta para ejecutar el instalador
            # -ArgumentList: Parámetros para ejecutar junto a los instladores (instalación silenciosa), todos los argument list son basados en los paquetes de software center... excepto para Chrome y Dell Command Update
            # -Wait: Experar a que acabe el proceso ejecutado en Start-Process
            try {
                # Ejecución de instalador AutoDesk_DWG2021, bajo parametros /Q /W /I Setup.ini
                Write-Host "AutoDesk Installation Procedure Started..."
                Start-Process -FilePath "$rootPath\..\installation_folder\03-AutoDesk_DWG2021\Setup.exe" -ArgumentList "/Q /W /I setup.ini" -Wait 
            } catch { "Error during AutoDesk_DWG2020 Installation Procedure" }
            try {
                # Ejecución de instalador ChromeSetup.exe bajo parametros /silent /install
                Write-Host "Google Chrome Installation Procedure Started..."
                Start-Process -FilePath "$rootPath\..\installation_folder\04-Chrome\ChromeSetup.exe" -ArgumentList '/silent /install' -Wait 
            } catch { "Error during Google Chrome Installation Procedure" }
            try { 
                # Ejecución de instalador SP8 bajo parametros /SAPGUi770_SP8_20220921_1358.exe /Silent
                Write-Host "SAP (SP8) Installation Procedure Procedure Started..."
                Start-Process -FilePath "$rootPath\..\installation_folder\06-SAP Installer\SAPGUi770_SP8_20220921_1358.exe" -ArgumentList "SAPGUi770_SP8_20220921_1358.exe /Silent" -Wait 
            } catch { "Error during SAP (SP8) Installation Procedure" }
            
            <# Language Configuration Sequence #>
            # Bug L-02 (Sin solución...)
            #                 [verificar]
            Set-TimeZone -Id "Central Standard Time (Mexico)"
            Set-Culture es-MX
            Set-Culture -CultureInfo es-MX
            Set-WinSystemLocale -SystemLocale es-MX
            Set-WinUILanguageOverride -Language es-ES
            Set-WinUserLanguageList es-ES -Force
            Get-WinHomeLocation
            Set-WinHomeLocation -GeoId 166
            Get-WinHomeLocation
            
            # Verificación de sistema operativo
            # Sí DELL = verdad{
            #   Instalar DELL Command Update
            # } Sí no {
            #   Saltar
            # }
            if ($os -like "*Dell Inc.*") {
                Write-Host "DELL Command Update Installation Procedure Started..."
                try { Start-Process -FilePath "$rootPath\..\installation_folder\05-Dell-Command-Update\Dell-Command-Update-Application_44TH5_WIN_5.1.0_A00.EXE" -ArgumentList "/factoryinstall /s" -Wait } catch { "Error during Dell Command Update Installation Procedure" }

                # Pausa de 10 segundos para actualización correcta de PATH
                Start-Sleep 10
                # Ejecución de Dell Command Update
                Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\DellCommandUpdate.exe" -Wait
            }
            
            Write-Host "Automated Process Finished... It's necesary to restart..."
            $restart_input = Read-Host "Restart? [y/n]"
            if ($restart_input -eq 'y') {
                shutdown -r
            }
        }

        # Secuencia de reparación de Software Center
        'Software Center Check' {
            Write-Host "Software Center Repair Sequence..."
            do {

                # Ejecución de Software Center
                # Bug: S-03 [fixed]
                Start-Process 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Configuration Manager\Configuration Manager\Software Center.lnk' -Wait

                # Si software center está azul se ejecuta una "secuencia de reparación"...
                # Se busca el archivo ccmrepair.exe dentro de Windows/CCM/, se ejecuta y espera para ejecutar CcmRestart.exe y se abren las actions para ejecutarlas
                $repairInput = Read-Host "Repair [y/n]"
                if ($repairInput -eq 'y') {
                    Start-Process 'C:\Windows\CCM\ccmrepair.exe' -Wait
                    Start-Process 'C:\Windows\CCM\CcmRestart.exe' -Wait
                    Start-Process "control.exe" -ArgumentList "smscfgrc" -Wait
                }

                # Si la secuencia no ha reparado software center, entonces se puede volver a ejecutar o cancelar...
            } until ($repairInput -eq 'n')
        }

        # Generación / Actualización automática de directorios de instalación manual [Bajo desarrollo: Branch 02.03 - Upgrade Sequence]
        # Bug 26 - Diciembre - 2023 (Angor):
        #                     Net User not identified - a67e-02
        #
        #                     -AsSecureString attribute (return failed) - Verificación (convertTo Method) 
        #                     https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/convertto-securestring?view=powershell-7.4
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

        # Coppy
        'Crear respaldo'{
            # Source [Bajo desarrollo: Branch 03.01 - AutoCopy Sequence]
            Write-Host ".\"
        }

        # OutStage
        'exit' {
            Write-Host "Exit"
            return
        }
    }
}

until ($optionMenuSelected -eq 'exit')
