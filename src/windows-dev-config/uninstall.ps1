[CmdletBinding()]
param()

& {
    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version Latest

    $env:PSModulePath = "$PSHOME\Modules;$env:PSModulePath"

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    # This fork runs its unsigned src/ copy, so there is no Microsoft signature check.
    $payloadRef = 'main'
    $bootstrap = (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/GrayArashiAI/WindowsDeveloperConfig/$payloadRef/src/windows-dev-config/bootstrap.ps1" -UseBasicParsing -TimeoutSec 60).TrimStart([char]0xFEFF)
    & ([scriptblock]::Create($bootstrap)) -Ref $payloadRef -Action Uninstall -AllowUnsigned
}
