
Import-Module .\bluetooth_disable.psm1
Import-Module .\bitlocker_disable.psm1
Import-Module .\language_config.psm1

## Write-Host "Test"

$Options = "Software Center Check", "Config Sequence", "Exit"

$xmin = 3
$ymin = 3

#Write Menu
Clear-Host
Write-Host ""
Write-Host " Use the up / down arrow to navigate and Enter to make a selection "
[Console]::SetCursorPosition(0, $ymin)
for each($name in $List){
  for($i = 0; $i -lt $xmin; $i++){
    Write-Host " " -NoNewLine
  }
  Write-Host " " -NoNewLine
}

function Write-Highlighted{
  [Console]::SetCursorPosition(1 + $xmin, $cursorY + $ymin)
  Write-Host ">" -BackgroundColor Yellow -ForegroundColor Black -NoNewLine
  Write-Host " " + $List[$cursorY] -BackgroundColor Yellow -ForegroundColor Black
  [Console]::SetCursorPosition(0, $cursorY + $ymin)
}

function Write-Normal{
  [Console]::SetCursorPosition(1 + $xmin, $cursorY + $ymin)
  Write-Host " " + $List[$cursorY]
}

$cursorY = 0
Write-Highlighted

$selection = ""
$menu_active = $true
while ($menu_active) {
    if ([console]::KeyAvailable) {
        $x = $Host.UI.RawUI.ReadKey()
        [Console]::SetCursorPosition(1, $cursorY)
        Write-Normal
        switch ($x.VirtualKeyCode) { 
            38 {
                #down key
                if ($cursorY -gt 0) {
                    $cursorY = $cursorY - 1
                }
            }
 
            40 {
                #up key
                if ($cursorY -lt $List.Length - 1) {
                    $cursorY = $cursorY + 1
                }
            }
            13 {
                #enter key
                $selection = $List[$cursorY]
                $menu_active = $false
            }
        }
        Write-Highlighted
    }
    Start-Sleep -Milliseconds 5 #Prevents CPU usage from spiking while looping
}

# Export-ModuleMember -Function Write-Highlighted
# Export-ModuleMember -Function Write-Normal
