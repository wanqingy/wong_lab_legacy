# Windows (PowerShell 2.0+, works on Windows 7) version of upload.sh
# Usage:  powershell -ExecutionPolicy Bypass -File upload.ps1 [-DryRun] [-Only substring] [-Map mapping.tsv] [-Rclone C:\path\rclone.exe] [-Drive E]
# Reads type<TAB>source<TAB>dest rows. Sources are written as /mnt/e/... in the TSV; they are
# converted to <Drive>:\... here, so the same mapping file works on both machines.
param(
    [switch]$DryRun,
    [string]$Only = "",
    [string]$Map = "",
    [string]$Rclone = "rclone",
    [string]$Drive = "E"
)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($Map -eq "") { $Map = Join-Path $here "mapping.tsv" }
$remote = "bossdbwong:upload-bossdb-3gqks4kjnacpujok"
$log = Join-Path $here ("upload_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log")

function Log($msg) { Write-Host $msg; Add-Content -Path $log -Value $msg }

foreach ($line in Get-Content $Map) {
    if ($line.Trim() -eq "" -or $line.StartsWith("#")) { continue }
    $f = $line -split "`t"
    if ($f.Length -lt 3) { Log "BAD ROW: $line"; continue }
    $type = $f[0]; $src = $f[1]; $dest = $f[2]

    if ($Only -ne "" -and $dest.IndexOf($Only) -lt 0) { continue }

    # /mnt/e/Allen grant data/... -> E:\Allen grant data\...
    $src = $src -replace '^/mnt/[a-zA-Z]/', ($Drive + ":/")
    $src = $src -replace '/', '\'

    if (-not (Test-Path -LiteralPath $src)) { Log "MISSING: $src"; continue }
    Log ">> ${type}: $src -> $dest"

    $common = @("--s3-no-check-bucket", "--stats", "30s", "--stats-one-line", "--log-file", $log, "--log-level", "INFO")
    if ($DryRun) { $common += "--dry-run" }

    if ($type -eq "dirtif") {
        $a = @("copy", $src, "$remote/$dest", "--include", "*.tif", "--include", "*.TIF",
               "--transfers", "8", "--s3-chunk-size", "64M") + $common
    } elseif ($type -eq "file") {
        $a = @("copyto", $src, "$remote/$dest") + $common
    } else {
        Log "BAD TYPE: $type"; continue
    }

    & $Rclone @a
    if ($LASTEXITCODE -ne 0) { Log "FAILED: $src (exit $LASTEXITCODE)" }
}
Log "done"
