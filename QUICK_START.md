# راهنمای سریع استفاده از Docker Image Backup

## این فایل شامل چه چیزهایی است؟

- فایل‌های Docker image در پوشه `docker-images/`
- یک `README.md` اختصاصی داخل پوشه هر image با لینک دانلود و دستورهای آماده
- manifest و checksum برای بررسی صحت فایل
- اسکریپت‌های restore برای Linux، macOS و Windows

## راحت‌ترین روش بازیابی

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

## نصب ابزارهای مورد نیاز

Windows با Chocolatey:

```powershell
choco install zstd gzip xz
```

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y zstd gzip xz-utils
```

macOS با Homebrew:

```bash
brew install zstd xz
```

## بازیابی دستی

اگر فایل split شده باشد، معمولا فایل‌هایی شبیه این دارید:

```text
docker-images/my-image/my-image.part-001
docker-images/my-image/my-image.part-002
docker-images/my-image/my-image.manifest.json
docker-images/my-image/README.md
```

اول فایل `docker-images/my-image/README.md` را باز کنید. آن فایل دستورهای دقیق دانلود، بررسی checksum و `docker load` را برای همان image دارد.

برای zstd:

```bash
cat docker-images/my-image/my-image.part-* | zstd -d -c | docker load
```

برای gzip:

```bash
cat docker-images/my-image/my-image.part-* | gunzip -c | docker load
```

برای xz:

```bash
cat docker-images/my-image/my-image.part-* | xz -d -c | docker load
```

اگر فایل split نشده باشد:

```bash
zstd -d -c docker-images/my-image/my-image.tar.zst | docker load
gunzip -c docker-images/my-image/my-image.tar.gz | docker load
xz -d -c docker-images/my-image/my-image.tar.xz | docker load
docker load -i docker-images/my-image/my-image.tar
```

## بررسی موفقیت

بعد از اجرای restore باید خروجی شبیه این ببینید:

```text
Loaded image: nginx:alpine
```

برای تایید:

```bash
docker images
```

## خطاهای رایج

اگر Docker اجرا نیست:

```bash
docker --version
docker info
```

اگر فایل خراب دانلود شده:

```bash
find docker-images -name "*.sha256" -execdir sha256sum -c {} \;
```

اگر `zstd` نصب نیست، از بخش نصب ابزارهای مورد نیاز همین فایل استفاده کنید.
