
function Disable-BitLocker {
    $DriveLetter = "C"

    # Bitlocker Status
    $status = Get-BitLockerVolume -MountPoint $DriveLetter

    if ($status.VolumeStatus -eq 'FullyEncrypted') {
        Disable-BitLocker -MountPoint $DriveLetter
        Write-Host "BitLocer inactive: $DriveLetter."
    }
    else {
        Write-Host "BitLocker is not active: $DriveLetter."
    }
}
