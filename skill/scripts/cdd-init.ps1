#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Scaffold a CDD project (CDD-BOOT.md "Where the work lives on disk").

.DESCRIPTION
  Creates the file spine CDD assumes, copying templates from this skill bundle:

      <Project>/CONSTITUTION.md          global, persists across features
      <Project>/CDD-STATE.md             the cross-session memory hub (T6)
      <Project>/specs/<NNN>/             per-feature directory

  Nothing existing is ever overwritten unless -Force is given. Missing files are reported
  as created; existing files are reported as skipped, so re-running is always safe.

  This script does NOT choose the project location for you. CDD leaves that to the user;
  pass the directory the user confirmed.

.PARAMETER Project
  Project directory. Created if absent.

.PARAMETER Feature
  Feature number for the first specs/ directory. Default 001.

.PARAMETER Force
  Overwrite existing template files.

.EXAMPLE
  ./cdd-init.ps1 -Project 'E:\Harness\common\erciyuan'
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Project,

    [ValidatePattern('^\d{3}$')]
    [string] $Feature = '001',

    [switch] $Force
)

$ErrorActionPreference = 'Stop'

$skillRoot = Split-Path -Parent $PSScriptRoot
$stateTemplate = Join-Path $skillRoot 'references/CDD-STATE.md'
$constitutionTemplate = Join-Path $skillRoot 'references/CONSTITUTION.md'

foreach ($t in @($stateTemplate, $constitutionTemplate)) {
    if (-not (Test-Path -LiteralPath $t -PathType Leaf)) {
        Write-Error "template missing from skill bundle: $t"
        exit 1
    }
}

if (-not (Test-Path -LiteralPath $Project)) {
    New-Item -ItemType Directory -Force -Path $Project | Out-Null
    Write-Output "created  $Project/"
}

$projectFull = (Resolve-Path -LiteralPath $Project).Path
$featureDir = Join-Path (Join-Path $projectFull 'specs') $Feature
New-Item -ItemType Directory -Force -Path $featureDir | Out-Null

$plan = @(
    @{ Source = $constitutionTemplate; Target = Join-Path $projectFull 'CONSTITUTION.md' }
    @{ Source = $stateTemplate;        Target = Join-Path $projectFull 'CDD-STATE.md' }
)

foreach ($entry in $plan) {
    $rel = $entry.Target.Substring($projectFull.Length).TrimStart('\', '/')
    if ((Test-Path -LiteralPath $entry.Target) -and -not $Force) {
        Write-Output "skipped  $rel (exists; use -Force to overwrite)"
        continue
    }
    if ($PSCmdlet.ShouldProcess($entry.Target, 'write CDD template')) {
        Copy-Item -LiteralPath $entry.Source -Destination $entry.Target -Force
        Write-Output "created  $rel"
    }
}

Write-Output "created  specs/$Feature/"

Write-Output ''
Write-Output 'Next steps (CDD boot sequence, in order):'
Write-Output '  1. [COST GATE] full CDD or lightweight? State it in one line.'
Write-Output '  2. Fill Article 0 of CONSTITUTION.md (project name, one-sentence goal, platform, users, sensitivity).'
Write-Output '  3. Record the cost-gate mode in CDD-STATE.md -> Session Configuration.'
Write-Output "  4. Print [FAST PATH CHECK], then emit UA-1 and stop. Do not write requirement.md as locked."
Write-Output '  5. A blank CDD-STATE.md is genuine S0 state, not a silent reset - confirm the top decisions.'
