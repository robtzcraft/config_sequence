
function Authentication {

  Clear-Host
  Write-Host ""
  Write-Host " Please Add Credentials "
  [string]$networkID = Read-Host "Network ID (600XXXXX / 18XXXXXXX): "
  [string]$networkIDPassword = Read-Host "Password: ", Password

  try {
    Net User \\tnsafs02.tenaris.techint.net\Packages\ /user:$networkID $networkIDPassword
    Write-Host "Authentication Succesfull... Welcome $networkID"
    Write-Host " "
    Write-Host " "
    Start-Sleep 5
    return 'Authentication True'
  }
  catch { 
    "Error... Authentication Failed $($_.Exception.Message)"
    Start-Sleep 5
    return 'Authentication False'
  }

}

Export-ModuleMember -Function Authentication
