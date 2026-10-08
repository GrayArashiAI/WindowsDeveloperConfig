<#
.SYNOPSIS
  Microsoft Edge policy tweaks: no first-run experience.
#>

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Invoke-EdgePhase {
    $tweaks = @(
        @{ Name = 'EdgeOOBE';   KeyPath = 'HKLM\SOFTWARE\Policies\Microsoft\Edge'; ValueName = 'HideFirstRunExperience'; Value = 1;          Type = 'DWord';  Description = 'Disable Edge first-run experience' }
    )

    $steps = foreach ($tweak in $tweaks) {
        New-DevConfigRegistryStep -Setting $tweak -Reset:($Script:DevConfigAction -eq 'Uninstall')
    }

    Invoke-DevConfigSteps -Steps $steps
}
