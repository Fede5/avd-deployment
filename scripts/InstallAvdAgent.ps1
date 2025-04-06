<#
.SYNOPSIS
Installs the Azure Virtual Desktop Agent and Agent Bootloader, then registers the agent using a provided registration token.

.DESCRIPTION
This script downloads the necessary AVD agent MSI installers from official Microsoft URLs,
installs them silently, and uses the provided registration token during the agent installation
to register the session host with the specified Host Pool.

.PARAMETER RegistrationToken
The registration token obtained from the AVD Host Pool. This is mandatory.

.EXAMPLE
.\InstallAvdAgent.ps1 -RegistrationToken "YOUR_SECURE_TOKEN_HERE"

.NOTES
- Ensure this script is run with Administrator privileges.
- The script requires internet connectivity to download the installers.
- Verify the download URLs ($avdAgentUrl, $avdAgentBootloaderUrl) point to the latest official versions if necessary.
- Error handling is included, and the script will exit with a non-zero code on failure.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$RegistrationToken
)

$ErrorActionPreference = 'Stop' # Exit script on any error
Write-Host "Starting AVD Agent Installation and Registration..."
Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')"

# Input validation
if ([string]::IsNullOrWhiteSpace($RegistrationToken)) {
    Write-Error "RegistrationToken parameter cannot be empty."
    exit 1
}

# URLs de los agentes (Verifica las URLs oficiales en la documentación de Microsoft, estas son ejemplos)
$avdAgentUrl = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv'
$avdAgentBootloaderUrl = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH'
$tempPath = $env:TEMP

# Define nombres de archivo únicos para evitar conflictos si se ejecuta varias veces
$guid = [guid]::NewGuid().ToString()
$agentFile = Join-Path $tempPath "Microsoft.RDInfra.RDAgent.Installer-x64-$guid.msi"
$bootloaderFile = Join-Path $tempPath "Microsoft.RDInfra.RDAgentBootLoader.Installer-x64-$guid.msi"

try {
    Write-Host "Downloading AVD Agent from $avdAgentUrl..."
    Invoke-WebRequest -Uri $avdAgentUrl -OutFile $agentFile -UseBasicParsing -TimeoutSec 300 # Aumentar timeout si es necesario
    Write-Host "Successfully downloaded Agent to $agentFile"

    Write-Host "Downloading AVD Agent Bootloader from $avdAgentBootloaderUrl..."
    Invoke-WebRequest -Uri $avdAgentBootloaderUrl -OutFile $bootloaderFile -UseBasicParsing -TimeoutSec 300
    Write-Host "Successfully downloaded Bootloader to $bootloaderFile"

    Write-Host "Installing AVD Agent Bootloader ($bootloaderFile)..."
    $msiArgsBootloader = @(
        '/i'
        "`"$bootloaderFile`"" # Comillas para manejar espacios en $tempPath
        '/qn' # Instalación silenciosa
        '/norestart'
        '/L*v' # Log detallado
        "`"$env:TEMP\avd_bootloader_install_$guid.log`""
    )
    Write-Host "Executing: msiexec.exe $($msiArgsBootloader -join ' ')"
    $processBootloader = Start-Process msiexec.exe -ArgumentList $msiArgsBootloader -Wait -PassThru
    if ($processBootloader.ExitCode -ne 0) {
        Write-Error "AVD Agent Bootloader installation failed with exit code $($processBootloader.ExitCode). Check log: $env:TEMP\avd_bootloader_install_$guid.log"
        exit $processBootloader.ExitCode
    }
    Write-Host "AVD Agent Bootloader installed successfully."


    Write-Host "Installing AVD Agent ($agentFile) and Registering with token..."
    # Pasar el token como propiedad MSI. ¡El token NO se loguea aquí!
    $msiArgsAgent = @(
        '/i'
        "`"$agentFile`"" # Comillas para manejar espacios en $tempPath
        '/qn' # Instalación silenciosa
        '/norestart'
        "REGISTRATIONTOKEN=$RegistrationToken" # El instalador usa este token
        '/L*v' # Log detallado
        "`"$env:TEMP\avd_agent_install_$guid.log`""
    )
    Write-Host "Executing: msiexec.exe $($msiArgsAgent -join ' ' | Select-String -Pattern 'REGISTRATIONTOKEN=\S+' -Replace 'REGISTRATIONTOKEN=********')" # Log comando ofuscando token
    $processAgent = Start-Process msiexec.exe -ArgumentList $msiArgsAgent -Wait -PassThru
    if ($processAgent.ExitCode -ne 0) {
        Write-Error "AVD Agent installation failed with exit code $($processAgent.ExitCode). Check log: $env:TEMP\avd_agent_install_$guid.log"
        # Considera intentar desinstalar el bootloader si el agente falla? (Complejo)
        exit $processAgent.ExitCode
    }
    Write-Host "AVD Agent installation and registration process initiated successfully."

} catch {
    Write-Error "An error occurred during AVD Agent setup: $_"
    # Intentar obtener más detalles si es posible
    if ($_.Exception) {
        Write-Error "Exception Details: $($_.Exception | Format-List -Force | Out-String)"
    }
    exit 1 # Salir con error genérico si no hay código de salida específico
} finally {
    # Limpiar archivos descargados (opcional)
    Write-Host "Cleaning up downloaded files..."
    if (Test-Path $agentFile) { Remove-Item $agentFile -Force -ErrorAction SilentlyContinue }
    if (Test-Path $bootloaderFile) { Remove-Item $bootloaderFile -Force -ErrorAction SilentlyContinue }
    Write-Host "Cleanup complete."
}

Write-Host "Script finished successfully."
exit 0 # Éxito explícito