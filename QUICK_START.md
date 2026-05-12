# راهنمای سریع Docker Image Backup

این فایل نسخه کوتاه راهنماست. برای هر image، راهنمای اصلی داخل همان فولدر ساخته می‌شود:

```text
docker-images/<image-name>/README.md
```

مثال:

```text
docker-images/bugsink-bugsink/README.md
```

## روش پیشنهادی

1. وارد فولدر image شوید.
2. فایل `README.md` همان فولدر را باز کنید.
3. دستورهای مخصوص همان image و همان compression را اجرا کنید.

## ابزارهای مورد نیاز

- Docker Desktop: https://www.docker.com/products/docker-desktop/
- Docker installation docs: https://docs.docker.com/engine/install/
- zstd: https://github.com/facebook/zstd/releases
- XZ Utils: https://tukaani.org/xz/
- gzip for Windows: https://gnuwin32.sourceforge.net/packages/gzip.htm

در حالت پیش‌فرض backupها بدون فشرده‌سازی ساخته می‌شوند، پس برای restore فقط Docker لازم است. ابزارهای zstd، gzip یا xz فقط وقتی لازم می‌شوند که موقع ساخت backup همان compression را انتخاب کرده باشید.

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y zstd gzip xz-utils
```

macOS:

```bash
brew install zstd xz
```

Windows با Chocolatey:

```powershell
choco install zstd gzip xz
```

## بازیابی با اسکریپت‌ها

Linux:

```bash
chmod +x scripts/restore-linux.sh
./scripts/restore-linux.sh
```

macOS:

```bash
chmod +x scripts/restore-mac.sh
./scripts/restore-mac.sh
```

Windows PowerShell:

```powershell
.\scripts\restore-windows.ps1
```

## بازیابی دستی split پیش‌فرض

اگر فایل‌ها این شکلی هستند:

```text
my-image.tar.part-000
my-image.tar.part-001
```

Linux/macOS:

```bash
cat my-image.tar.part-* > my-image.tar
docker load -i my-image.tar
docker images
```

Windows PowerShell:

```powershell
$out = [System.IO.File]::Create("my-image.tar")
Get-ChildItem -Filter "my-image.tar.part-*" | Sort-Object Name | ForEach-Object {
    $in = [System.IO.File]::OpenRead($_.FullName)
    try { $in.CopyTo($out) } finally { $in.Close() }
}
$out.Close()
docker load -i my-image.tar
docker images
```

## بازیابی دستی zstd split

اگر فایل‌ها این شکلی هستند:

```text
my-image.tar.zst.part-000
my-image.tar.zst.part-001
```

Linux/macOS:

```bash
cat my-image.tar.zst.part-* > my-image.tar.zst
zstd -d -c my-image.tar.zst | docker load
docker images
```

Windows PowerShell:

```powershell
$out = [System.IO.File]::Create("my-image.tar.zst")
Get-ChildItem -Filter "my-image.tar.zst.part-*" | Sort-Object Name | ForEach-Object {
    $in = [System.IO.File]::OpenRead($_.FullName)
    try { $in.CopyTo($out) } finally { $in.Close() }
}
$out.Close()
zstd -d -c my-image.tar.zst | docker load
docker images
```

## SHA256

فایل `.sha256` برای بررسی سالم دانلود شدن فایل‌هاست:

```bash
sha256sum -c my-image.sha256
```

این checksum نشان می‌دهد قطعه‌هایی که دانلود کرده‌اید همان قطعه‌هایی هستند که GitHub Action ساخته و فایل‌ها ناقص یا خراب دانلود نشده‌اند.
