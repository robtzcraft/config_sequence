

function Disable-Bluetooth {
  # Obtiene el estado actual del Bluetooth
  $state = Get-WmiObject -Class Win32_BluetoothRadio -Namespace root\cimv2\wirelesslan

  # Verifica si el Bluetooth está activado
  if ($state.Enabled) {
    # Desactiva el Bluetooth
    $state.Enabled = $false
    $state.SetProperty()

    # Imprime un mensaje de confirmación
    Write-Host "El Bluetooth se ha deshabilitado."
  } else {
    # Imprime un mensaje de advertencia
    Write-Host "El Bluetooth ya está deshabilitado."
  }
}


