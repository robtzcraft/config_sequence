
function Disable-VolumeBitLocker {
    param (
      [Parameter(Mandatory = $true)]
      [string] $MountPoint
    )

    $MountPoint = 'C'
  
    # Check if BitLocker is enabled on the specified volume
    $volumeInfo = Get-BitLockerVolume -MountPoint $MountPoint
  
    if (!$volumeInfo.ProtectionStatus -eq "BitLockerProtectionOff") {
      Write-Host "BitLocker is not enabled on volume '$MountPoint'. Skipping decryption."
      return
    }
  
    # Check for and remove automatic unlocking keys (if existing)
    if ($volumeInfo.HasAutomaticUnlockers) {
      Write-Host "Removing automatic unlocking keys for volume '$MountPoint'..."
      Clear-BitLockerAutoUnlock -MountPoint $MountPoint
    }
  
    # Disable BitLocker and start decryption
    Write-Host "Disabling BitLocker and decrypting volume '$MountPoint'..."
    Disable-BitLocker -MountPoint $MountPoint
  
    # Monitor decryption progress (using do-while loop)
    do {
      $volumeInfo = Get-BitLockerVolume -MountPoint $MountPoint
      $percentDecrypted = $volumeInfo.ConversionPercentage
  
      Write-Progress -Activity "Decrypting..." -Status "$percentDecrypted% complete" -PercentComplete $percentDecrypted
  
      if ($retryCount++ -gt 10) {
        Write-Error "Decryption is taking too long. Please check the drive health."
        return
      }
  
      Start-Sleep -Seconds 5
    } while ($percentDecrypted -lt 100)
  
    Write-Host "Volume '$MountPoint' successfully decrypted."
}  

Export-ModuleMember -Function Disable-VolumeBitLocker
