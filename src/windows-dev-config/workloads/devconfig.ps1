<#
.SYNOPSIS
  Windows Dev Config: developer tools, Windows settings, fonts, Terminal, and WSL + Ubuntu.

.DESCRIPTION
  Workload definition read by dev-config.ps1. It only lists phases; the phase files under
  steps\ do the work. This is the default workload behind setup-full.ps1,
  setup-standard.ps1 (Partial), and uninstall.ps1.
#>

[CmdletBinding()]
param(
    [string] $Action = 'Full'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$phases = @(
    @{
        File     = 'prerequisites.ps1'
        Function = 'Invoke-PrerequisitesPhase'
        Title    = 'Getting ready'
    }
    @{
        File       = 'packages.ps1'
        Function   = 'Invoke-PackagesPhase'
        Title      = 'Packages'
        Uninstall  = $true
        # Install order; names refer to the package catalog in steps\packages.ps1.
        Parameters = @{
            Packages = @(
                'Terminal'
                'IntelligentTerminal'
                'PowerShell'
                'Git'
                'GitHubCLI'
                'VSCode'
                'DotnetSdk'
                'Python'
                'VCRedist'
                'UV'
                'NodeJS'
                'nvmForNode'
                'Coreutils'
                'winappCli'
                'PowerToys'
            )
        }
    }
    @{
        File      = 'registry-system.ps1'
        Function  = 'Invoke-RegistrySystemPhase'
        Title     = 'System settings'
        Uninstall = $true
    }
    @{
        File      = 'registry-explorer.ps1'
        Function  = 'Invoke-RegistryExplorerPhase'
        Title     = 'File Explorer tweaks'
        Uninstall = $true
    }
    @{
        File      = 'registry-taskbar-search.ps1'
        Function  = 'Invoke-RegistryTaskbarSearchPhase'
        Title     = 'Taskbar, search & start tweaks'
        Uninstall = $true
    }
    @{
        File      = 'edge.ps1'
        Function  = 'Invoke-EdgePhase'
        Title     = 'Microsoft Edge tweaks'
        Uninstall = $true
    }
    @{
        File      = 'terminal.ps1'
        Function  = 'Invoke-TerminalPhase'
        Title     = 'Windows Terminal'
        Uninstall = $true
    }
    @{
        # Only the WinUI templates step; the Copilot profile and plugin steps are skipped.
        File      = 'copilot.ps1'
        Function  = 'Invoke-CopilotPhase'
        Title     = 'WinUI templates'
        Uninstall = $true
        Steps     = if ($Action -eq 'Uninstall') { @('WinUITemplatesCleanup') } else { @('WinUITemplates') }
    }
)
if ($Action -eq 'Partial') {
    # Partial setup has no WinUI templates step, so the copilot.ps1 phase has nothing left to run.
    $phases = @($phases | Where-Object { $_.File -ne 'copilot.ps1' })
    # The lite setup skips the two largest downloads.
    $packages = ($phases | Where-Object { $_.File -eq 'packages.ps1' }).Parameters
    $packages.Packages = @($packages.Packages | Where-Object { $_ -notin @('DotnetSdk', 'PowerToys') })
} elseif ($Action -eq 'Uninstall') {
    $phases = @($phases | Where-Object { $_['Uninstall'] })
    # Reset Terminal after removing the tools and WSL fragments that can recreate profiles.
    $phases = @($phases | Where-Object { $_.File -notin @('packages.ps1', 'terminal.ps1') }) +
        @($phases | Where-Object { $_.File -eq 'packages.ps1' }) +
        @($phases | Where-Object { $_.File -eq 'terminal.ps1' })
}

@{
    Name             = 'Calm OS'
    Actions          = @('Full', 'Partial', 'Uninstall')
    UninstallWarning = 'Targeted tools are removed even if they predate setup.'
    Notes            = @('A few Explorer and taskbar changes appear once you sign out and back in.')
    Phases           = $phases
}
