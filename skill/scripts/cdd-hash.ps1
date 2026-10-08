#!/usr/bin/env pwsh
<#
.SYNOPSIS
  CDD artifact weak-hash calculator (CDD-BOOT.md §T6 / CDD-STATE.md Artifact Register).

.DESCRIPTION
  Produces the uniform weak-hash form the CDD state file requires:
      <sha256 first 12 hex chars>            (uppercase, no separators)
  If a hash cannot be computed, falls back to the specified alternate form:
      chars=<n>;first=<first 40 chars>;last=<last 40 chars>
  and states which form was used, so records stay comparable across sessions.

.PARAMETER Path
  One or more artifact files to hash.

.PARAMETER Register
  Emit a ready-to-paste row for the state file's Artifact Register:
      | <name> | <relative path> | locked | <date> | <deps> | <hash> |

.PARAMETER Upstream
  Upstream dependency text used by -Register (default: "-").

.EXAMPLE
  ./cdd-hash.ps1 spec.md
  ./cdd-hash.ps1 specs/001/spec.md -Register -Upstream "feature spec"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromRemainingArguments = $true)]
    [string[]] $Path,

    [switch] $Register,

    [string] $Upstream = '-',

    [string] $Status = 'locked'
)

$ErrorActionPreference = 'Stop'
$exit = 0

foreach ($item in $Path) {
    if (-not (Test-Path -LiteralPath $item -PathType Leaf)) {
        Write-Error "not a file: $item"
        $exit = 1
        continue
    }

    $full = (Resolve-Path -LiteralPath $item).Path
    $bytes = [System.IO.File]::ReadAllBytes($full)

    try {
        $hash = (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash
        $weak = $hash.Substring(0, 12)
        $form = 'sha256-first-12'
    }
    catch {
        $text = [System.Text.Encoding]::UTF8.GetString($bytes)
        $trimmed = $text.Trim()
        $first = if ($trimmed.Length -ge 40) { $trimmed.Substring(0, 40) } else { $trimmed }
        $last = if ($trimmed.Length -ge 40) { $trimmed.Substring($trimmed.Length - 40) } else { $trimmed }
        $weak = "chars=$($trimmed.Length);first=$first;last=$last"
        $form = 'fallback-chars'
    }

    if ($Register) {
        $name = Split-Path -Leaf $full
        Write-Output "| $name | $item | $Status | $(Get-Date -Format 'yyyy-MM-dd') | $Upstream | $weak |"
    }
    else {
        Write-Output "$weak`t$full"
        Write-Output "form: $form | bytes: $($bytes.Length)"
    }
}

exit $exit
