
function Disable-Bluetooth {
    # Obtiene todos los objetos WMI de los dispositivos Bluetooth
    $devices = Get-WmiObject -Class Win32_PnPEntity -Filter "ClassGuid='{88820DD7-04D3-11D0-8D11-00AA0038C966}'"

    # Establece el estado de todos los dispositivos en "Deshabilitado"
    foreach ($device in $devices) {
        $device.Enabled = $false
        $device.Put()
    }

    # Obtén el adaptador de red Bluetooth
#    $bluetoothAdapter = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Bluetooth*" }

    # Verifica si el adaptador de red Bluetooth está activo
#    if ($bluetoothAdapter.Status -eq "OK") {
        # Si está activo, deshabilita el adaptador de red Bluetooth
#        Disable-PnpDevice -InstanceId $bluetoothAdapter.InstanceId -Confirm:$false
#        Write-Output "Bluetooth: Inactive"
#    }
#    else {
#        Write-Output "Bluetooth: Inactive"
#    }
#

Export-ModuleMember -Function Disable-Bluetooth
