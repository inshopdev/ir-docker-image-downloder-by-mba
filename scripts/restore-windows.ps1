param(
    [string]$ImageDir = ""
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "docker is required"
}

$RootDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
if ([string]::IsNullOrWhiteSpace($ImageDir)) {
    $ImageDir = Join-Path $RootDir "docker-images"
}

$Manifest = Get-ChildItem -Path $ImageDir -Filter "*.manifest.json" -Recurse | Sort-Object FullName | Select-Object -First 1
if (-not $Manifest) {
    throw "No manifest found in $ImageDir"
}

$ImageDir = $Manifest.DirectoryName
$Meta = Get-Content -Raw -Path $Manifest.FullName | ConvertFrom-Json
$Base = [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetFileNameWithoutExtension($Manifest.Name))
$Compression = $Meta.compression
$IsSplit = [bool]$Meta.split

Write-Host "Restoring $Base with compression: $Compression"

$ShaFile = Join-Path $ImageDir "$Base.sha256"
if (Test-Path $ShaFile) {
    Write-Host "SHA256 file found: $ShaFile"
}

function Invoke-DockerLoadFromProcess {
    param(
        [string]$Exe,
        [string[]]$Args
    )

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo.FileName = $Exe
    foreach ($arg in $Args) {
        [void]$process.StartInfo.ArgumentList.Add($arg)
    }
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.RedirectStandardError = $true
    $process.StartInfo.UseShellExecute = $false
    [void]$process.Start()

    $docker = New-Object System.Diagnostics.Process
    $docker.StartInfo.FileName = "docker"
    [void]$docker.StartInfo.ArgumentList.Add("load")
    $docker.StartInfo.RedirectStandardInput = $true
    $docker.StartInfo.RedirectStandardError = $true
    $docker.StartInfo.RedirectStandardOutput = $true
    $docker.StartInfo.UseShellExecute = $false
    [void]$docker.Start()

    $process.StandardOutput.BaseStream.CopyTo($docker.StandardInput.BaseStream)
    $docker.StandardInput.Close()

    $process.WaitForExit()
    $docker.WaitForExit()

    Write-Host $docker.StandardOutput.ReadToEnd()
    $err = $process.StandardError.ReadToEnd() + $docker.StandardError.ReadToEnd()
    if ($err.Trim().Length -gt 0) {
        Write-Host $err
    }
    if ($process.ExitCode -ne 0 -or $docker.ExitCode -ne 0) {
        throw "Restore failed"
    }
}

$TempCombined = $null
if ($IsSplit) {
    $parts = Get-ChildItem -Path $ImageDir -Filter "$Base.*.part-*" | Sort-Object Name
    if (-not $parts) {
        $parts = Get-ChildItem -Path $ImageDir -Filter "$Base.part-*" | Sort-Object Name
    }
    if (-not $parts) {
        throw "No split parts found for $Base"
    }
    $TempCombined = Join-Path $env:TEMP "$Base.compressed"
    if (Test-Path $TempCombined) {
        Remove-Item -Force $TempCombined
    }
    $out = [System.IO.File]::OpenWrite($TempCombined)
    try {
        foreach ($part in $parts) {
            $in = [System.IO.File]::OpenRead($part.FullName)
            try {
                $in.CopyTo($out)
            } finally {
                $in.Close()
            }
        }
    } finally {
        $out.Close()
    }
}

try {
    switch ($Compression) {
        "zstd" {
            if (-not (Get-Command zstd -ErrorAction SilentlyContinue)) { throw "zstd is required" }
            $file = if ($IsSplit) { $TempCombined } else { Join-Path $ImageDir "$Base.tar.zst" }
            Invoke-DockerLoadFromProcess "zstd" @("-d", "-c", $file)
        }
        "gzip" {
            $file = if ($IsSplit) { $TempCombined } else { Join-Path $ImageDir "$Base.tar.gz" }
            if (Get-Command gzip -ErrorAction SilentlyContinue) {
                Invoke-DockerLoadFromProcess "gzip" @("-d", "-c", $file)
            } else {
                throw "gzip is required"
            }
        }
        "xz" {
            if (-not (Get-Command xz -ErrorAction SilentlyContinue)) { throw "xz is required" }
            $file = if ($IsSplit) { $TempCombined } else { Join-Path $ImageDir "$Base.tar.xz" }
            Invoke-DockerLoadFromProcess "xz" @("-d", "-c", $file)
        }
        "none" {
            if ($IsSplit) {
                docker load -i $TempCombined
            } else {
                docker load -i (Join-Path $ImageDir "$Base.tar")
            }
        }
        default {
            throw "Unsupported compression: $Compression"
        }
    }
} finally {
    if ($TempCombined -and (Test-Path $TempCombined)) {
        Remove-Item -Force $TempCombined
    }
}

Write-Host "Restore completed."
