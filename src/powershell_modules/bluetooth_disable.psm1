
function Disable-Bluetooth {
    # Obtén el adaptador de red Bluetooth
    $bluetoothAdapter = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Bluetooth*" }

    # Verifica si el adaptador de red Bluetooth está activo
    if ($bluetoothAdapter.Status -eq "OK") {
        # Si está activo, deshabilita el adaptador de red Bluetooth
        Disable-PnpDevice -InstanceId $bluetoothAdapter.InstanceId -Confirm:$false
        Write-Output "Bluetooth: Inactive"
    }
    else {
        Write-Output "Bluetooth: Inactive"
    }
}

Export-ModuleMember -Function Disable-Bluetooth
