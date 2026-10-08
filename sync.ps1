<#
.SYNOPSIS
    One-way sync of the CDD repository to its mirrors, with hash verification.

.DESCRIPTION
    The repository is the single source of truth. Everything else is a mirror:

      F:\Clarify-Driven Development      full mirror, on a separate physical disk
      E:\Harness\common\agent-dev-kit    working copies + the vendored annex
      ~\.dsh\skills\clarify-driven-development   the bundle DSH actually loads

    Run it after any change to CDD-BOOT.md, README.md, upstream/ or skill/, then
    commit. It never writes back to the repository.

    Mapped *directories* are replaced wholesale, so a file deleted upstream cannot
    survive in a mirror. Mapped *files* are overwritten in place.

    Every copied file is then re-hashed and compared. The script exits non-zero if
    any target diverges, so it is safe to chain into a pre-commit or CI step.

.PARAMETER DryRun
    Report what would be copied without touching any target.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\sync.ps1 -DryRun
    powershell -ExecutionPolicy Bypass -File .\sync.ps1

.NOTES
    This script is itself mirrored to F:, where it refuses to run: the source of
    truth is the git checkout, and running the mirror would sync F: onto itself.
    If PowerShell refuses to load the file ("not digitally signed"), the execution
    policy is blocking script files - use -ExecutionPolicy Bypass as above, or
    Unblock-File this one file.
#>
[CmdletBinding()]
param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$Repo = $PSScriptRoot
$Home_ = [Environment]::GetFolderPath('UserProfile')

# The repository is the only place this may run. F: carries a copy of this file
# (it is part of the mirror set), and running that copy would treat F: as the
# source and sync it onto itself - silently, since every hash would match.
if (-not (Test-Path (Join-Path $Repo '.git'))) {
    throw "sync.ps1 must run from the CDD git checkout. '$Repo' has no .git - it is a mirror, not the source. Run the copy inside the repository instead."
}

# "From" or "From=To"; when To is omitted the destination path is identical.
$Targets = @(
    [pscustomobject]@{
        Name = 'F: full mirror'
        Root = 'F:\Clarify-Driven Development'
        Map  = @(
            'CDD-BOOT.md', 'CDD-STATE.md', 'README.md', 'LICENSE', '.gitattributes',
            '.gitignore', 'sync.ps1', 'docs', 'upstream', 'skill'
        )
    }
    [pscustomobject]@{
        Name = 'agent-dev-kit'
        Root = 'E:\Harness\common\agent-dev-kit'
        Map  = @('CDD-BOOT.md', 'CDD-STATE.md', 'upstream')
    }
    [pscustomobject]@{
        Name = 'installed DSH skill'
        Root = Join-Path $Home_ '.dsh\skills\clarify-driven-development'
        Map  = @(
            'skill/SKILL.md=SKILL.md'
            'skill/scripts=scripts'
            'skill/references/CONSTITUTION.md=references/CONSTITUTION.md'
            'skill/references/example-project=references/example-project'
            'CDD-BOOT.md=references/CDD-BOOT.md'
            'CDD-STATE.md=references/CDD-STATE.md'
            'upstream=references/upstream'
        )
    }
)

function Split-MapEntry {
    param([string]$Entry)
    $i = $Entry.IndexOf('=')
    if ($i -lt 0) { return [pscustomobject]@{ From = $Entry.Trim(); To = $Entry.Trim() } }
    return [pscustomobject]@{
        From = $Entry.Substring(0, $i).Trim()
        To   = $Entry.Substring($i + 1).Trim()
    }
}

Write-Host "source: $Repo`n"

# ---- guard: SKILL.md version must exist in the spec's version log -------------
$skillMd   = Join-Path $Repo 'skill\SKILL.md'
$specPath  = Join-Path $Repo 'CDD-BOOT.md'
$skillVer  = $null
if (Test-Path $skillMd) {
    $fm = Get-Content $skillMd -TotalCount 12
    $m  = $fm | Select-String -Pattern '^\s*version:\s*"?([0-9]+\.[0-9]+)"?' | Select-Object -First 1
    if ($m) { $skillVer = $m.Matches[0].Groups[1].Value }
    if (-not $skillVer) {
        Write-Warning 'skill/SKILL.md has no metadata.version - skipping the version cross-check.'
    } else {
        $spec = Get-Content $specPath -Raw
        if ($spec -notmatch [regex]::Escape("| **$skillVer** |") -and $spec -notmatch [regex]::Escape("| $skillVer |")) {
            Write-Warning "skill/SKILL.md says v$skillVer but CDD-BOOT.md's version log has no $skillVer row. Bump one of them."
        } else {
            Write-Host "version cross-check: SKILL.md v$skillVer found in the CDD-BOOT.md version log.`n"
        }
    }
}

$problems = 0
$copied   = 0

# ---- guard: Part 2 of the spec and CONSTITUTION.md must carry the same clauses --
# Article 5 exists in two places. Until v1.8 nothing compared them, so a clause
# added to one and forgotten in the other would ship silently.
$constPath = Join-Path $Repo 'skill\references\CONSTITUTION.md'
$part2 = [regex]::Match((Get-Content $specPath -Raw), '(?ms)^# Part 2:.*?(?=^# Part 3:)')
if (-not $part2.Success) {
    Write-Warning 'could not isolate Part 2 of CDD-BOOT.md - skipping the constitution cross-check.'
} elseif (-not (Test-Path $constPath)) {
    Write-Warning "skill/references/CONSTITUTION.md not found at $constPath - skipping the constitution cross-check."
} else {
    $clauseRx  = [regex]'(?m)^-\s+(?:\*\*)?(\d+\.\d+)'
    $inSpec    = @($clauseRx.Matches($part2.Value)                        | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    $inConst   = @($clauseRx.Matches((Get-Content $constPath -Raw))       | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    $onlySpec  = @($inSpec  | Where-Object { $_ -notin $inConst })
    $onlyConst = @($inConst | Where-Object { $_ -notin $inSpec })
    if ($onlySpec.Count -gt 0 -or $onlyConst.Count -gt 0) {
        Write-Warning 'constitution drift - the same articles are written in two places and they disagree:'
        if ($onlySpec.Count  -gt 0) { Write-Warning "   in CDD-BOOT.md Part 2 only: $($onlySpec  -join ', ')" }
        if ($onlyConst.Count -gt 0) { Write-Warning "   in CONSTITUTION.md only:    $($onlyConst -join ', ')" }
        $problems++
    } else {
        Write-Host "constitution cross-check: $($inSpec.Count) clauses present in both files.`n"
    }
}

foreach ($t in $Targets) {
    Write-Host "== $($t.Name)  ->  $($t.Root)"
    if (-not (Test-Path $t.Root)) {
        Write-Warning "   target root does not exist; skipping."
        $problems++
        continue
    }

    foreach ($entry in $t.Map) {
        $p    = Split-MapEntry $entry
        $src  = Join-Path $Repo $p.From
        $dst  = Join-Path $t.Root $p.To

        if (-not (Test-Path $src)) {
            Write-Warning "   source missing: $($p.From)"
            $problems++
            continue
        }

        $isDir = (Get-Item $src).PSIsContainer
        if ($DryRun) {
            Write-Host ("   would {0} {1}" -f $(if ($isDir) { 'replace dir ' } else { 'copy file   ' }), $p.To)
            continue
        }

        # directories are replaced wholesale so deletions propagate
        if ($isDir -and (Test-Path $dst)) { Remove-Item $dst -Recurse -Force }
        $parent = Split-Path $dst -Parent
        if ($parent -and -not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
        Copy-Item $src $dst -Recurse -Force

        # verify
        $srcFiles = if ($isDir) { Get-ChildItem $src -Recurse -File } else { @(Get-Item $src) }
        foreach ($f in $srcFiles) {
            $rel = if ($isDir) { $f.FullName.Substring($src.Length + 1) } else { '' }
            $target = if ($isDir) { Join-Path $dst $rel } else { $dst }
            if (-not (Test-Path $target)) {
                Write-Warning "   NOT COPIED: $($p.To)/$rel"
                $problems++
                continue
            }
            $a = (Get-FileHash $f.FullName -Algorithm SHA256).Hash
            $b = (Get-FileHash $target   -Algorithm SHA256).Hash
            if ($a -ne $b) {
                Write-Warning "   HASH MISMATCH: $($p.To)/$rel"
                $problems++
            } else {
                $copied++
            }
        }
    }
    Write-Host ''
}

if ($DryRun) {
    if ($problems -gt 0) {
        Write-Host "dry run: $problems problem(s) found - nothing was written." -ForegroundColor Red
        exit 1
    }
    Write-Host 'dry run - nothing to write.'
    exit 0
}

Write-Host "verified identical files: $copied"
if ($problems -gt 0) {
    Write-Host "PROBLEMS: $problems  -- mirrors diverge, fix before committing." -ForegroundColor Red
    exit 1
}
Write-Host 'all mirrors in sync.' -ForegroundColor Green
exit 0
