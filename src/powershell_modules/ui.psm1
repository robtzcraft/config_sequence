
function UI_menu {

  [array]$menuOptionList = @("Software Center Check", "Config Sequence", "Exit")

  #menu offset to allow space to write a message above the menu
  $xmin = 3
  $ymin = 3
 
  #Write Menu
  Clear-Host
  Write-Host ""
  Write-Host "  Use the up / down arrow to navigate and Enter to make a selection"
  [Console]::SetCursorPosition(0, $ymin)
  foreach ($name in $menuOptionList) {
      for ($i = 0; $i -lt $xmin; $i++) {
          Write-Host " " -NoNewline
      }
      Write-Host "   " + $name
  }
  
  #Highlights the selected line
  function Write-Highlighted {
  
      [Console]::SetCursorPosition(1 + $xmin, $cursorY + $ymin)
      Write-Host ">" -BackgroundColor Yellow -ForegroundColor Black -NoNewline
      Write-Host " " + $List[$cursorY] -BackgroundColor Yellow -ForegroundColor Black
      [Console]::SetCursorPosition(0, $cursorY + $ymin)     
  }
  
  #Undoes highlight
  function Write-Normal {
      [Console]::SetCursorPosition(1 + $xmin, $cursorY + $ymin)
      Write-Host "  " + $List[$cursorY]  
  }
  
  #highlight first item by default
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
  Clear-Host
  return $selection
}

Export-ModuleMember -Function UI