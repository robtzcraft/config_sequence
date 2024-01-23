
function Authentication {

  Clear-Host
  Write-Host ""
  Write-Host "Please Add Credentials"
  [string]$networkID = Read-Host "Network ID (600XXXXX / 18XXXXXXX)"
  [string]$networkIDPassword = Read-Host "Password" -AsSecureString

  try {
    net use \\tnsafs02.tenaris.techint.net\Packages /user:$networkID $networkIDPassword
    Set-Location \\tnsafs02.tenaris.techint.net\Packages\
    Write-Host "Authentication Succesfull... Welcome $networkID"
    Write-Host " "
    Write-Host " "
    Start-Sleep 5
    'Authentication True'
    return
  }
  catch {
    "Error... Authentication Failed $($_.Exception.Message)"
    Start-Sleep 5
    'Authentication False'
    return
  }

}

Export-ModuleMember -Function Authentication
