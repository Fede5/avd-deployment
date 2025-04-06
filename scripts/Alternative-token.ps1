param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$HostPoolName,

    [Parameter(Mandatory=$false)]
    [int]$ExpirationHours = 4 # Expiración por defecto de 4 horas
)

# Asegúrate de estar conectado a la suscripción correcta si ejecutas localmente
# Connect-AzAccount
# Set-AzContext -SubscriptionId 'TuSubscriptionId'

try {
    Write-Host "Getting registration token for Host Pool '$HostPoolName' in Resource Group '$ResourceGroupName'..."

    $expirationTime = (Get-Date).ToUniversalTime().AddHours($ExpirationHours)

    # Obtiene la información de registro (esto genera o actualiza el token)
    $regInfo = Get-AzWvdRegistrationInfo -ResourceGroupName $ResourceGroupName -HostPoolName $HostPoolName -ExpirationTime $expirationTime

    if ($regInfo -and $regInfo.Token) {
        Write-Host "Successfully retrieved registration token (valid until $($regInfo.ExpirationTime.ToString('u'))):"
        Write-Host "-----------------------------------------------------"
        # ¡¡¡PRECAUCIÓN DE SEGURIDAD!!! No expongas esto en logs de producción.
        Write-Host $regInfo.Token
        Write-Host "-----------------------------------------------------"
        Write-Host "WARNING: Do not expose this token in production logs. Store it securely (e.g., Key Vault)."

        # Para usar en Pipelines, podrías escribirlo como variable secreta:
        # Write-Host "##vso[task.setvariable variable=avdRegistrationToken;isOutput=true;isSecret=true]$($regInfo.Token)"

    } else {
        Write-Error "Failed to retrieve registration token."
    }
}
catch {
    Write-Error "An error occurred: $_"
    # Salir con error para que el pipeline falle si es necesario
    exit 1
}