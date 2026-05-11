You're absolutely right! Thank you for the correction. The `docker load -i image.compressed` worked because the file is already a Docker image archive (tar format), not a compressed file that needs decompression first.

Here's your **corrected documentation**:

---

# Docker image backup: `bugsink/bugsink`

This folder contains everything needed to download and load this Docker image without using Docker Hub.

## Files

- [bugsink-bugsink.part-000](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/bugsink-bugsink/bugsink-bugsink.part-000)
- [bugsink-bugsink.part-001](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/bugsink-bugsink/bugsink-bugsink.part-001)
- [bugsink-bugsink.manifest.json](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/bugsink-bugsink/bugsink-bugsink.manifest.json)
- [bugsink-bugsink.sha256](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/bugsink-bugsink/bugsink-bugsink.sha256)
- [bugsink-bugsink.info.txt](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/bugsink-bugsink/bugsink-bugsink.info.txt)

## Linux / macOS

### 1. Download the files

```bash
mkdir -p bugsink-bugsink
cd bugsink-bugsink
curl -L -o bugsink-bugsink.part-000 https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/bugsink-bugsink/bugsink-bugsink.part-000
curl -L -o bugsink-bugsink.part-001 https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/bugsink-bugsink/bugsink-bugsink.part-001
curl -L -o bugsink-bugsink.sha256 https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/bugsink-bugsink/bugsink-bugsink.sha256
```

### 2. Check the download

```bash
sha256sum -c bugsink-bugsink.sha256
```

### 3. Combine parts and load into Docker

```bash
cat bugsink-bugsink.part-* > image.tar
docker load -i image.tar
```

Or as a one-liner:

```bash
cat bugsink-bugsink.part-* | docker load
```

## Windows PowerShell

### 1. Download the files

```powershell
New-Item -ItemType Directory -Force bugsink-bugsink
Set-Location bugsink-bugsink
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/bugsink-bugsink/bugsink-bugsink.part-000" -OutFile "bugsink-bugsink.part-000"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/bugsink-bugsink/bugsink-bugsink.part-001" -OutFile "bugsink-bugsink.part-001"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/bugsink-bugsink/bugsink-bugsink.sha256" -OutFile "bugsink-bugsink.sha256"
```

### 2. Combine parts

```powershell
# Method 1: Using cmd (fastest)
cmd /c "copy /b bugsink-bugsink.part-* image.tar"

# Method 2: Using PowerShell
$out = [System.IO.File]::Create("image.tar")
Get-ChildItem -Filter "*.part-*" | Sort-Object Name | ForEach-Object {
    $in = [System.IO.File]::OpenRead($_.FullName)
    try { $in.CopyTo($out) } finally { $in.Close() }
}
$out.Close()
```

### 3. Load into Docker

```powershell
docker load -i image.tar
```

## Requirements

- Docker must be installed and running.
- No additional compression tools needed.

Generated at: `2026-05-11T07:27:24Z`

---

## Key changes made:
1. Removed `zstd` requirement since the parts combine directly to a Docker loadable tar
2. Changed from `image.compressed` to `image.tar` for clarity
3. Simplified loading to just `docker load -i image.tar` or `cat parts | docker load`
4. Removed the unnecessary decompression step
5. Added note that no additional tools are needed

The file is already in Docker's tar format, so no decompression utilities are required!
