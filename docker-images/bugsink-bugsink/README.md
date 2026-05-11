# Docker image backup: `bugsink/bugsink`

این فولدر همه چیز لازم برای دانلود و بازیابی این Docker image را دارد، بدون اینکه سیستم مقصد مستقیم به Docker Hub یا registry اصلی وصل شود.

## لینک فایل‌ها

- [bugsink-bugsink.tar.zst.part-000](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/bugsink-bugsink/bugsink-bugsink.tar.zst.part-000)
- [bugsink-bugsink.tar.zst.part-001](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/bugsink-bugsink/bugsink-bugsink.tar.zst.part-001)
- [bugsink-bugsink.manifest.json](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/bugsink-bugsink/bugsink-bugsink.manifest.json)
- [bugsink-bugsink.sha256](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/bugsink-bugsink/bugsink-bugsink.sha256)
- [bugsink-bugsink.info.txt](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/bugsink-bugsink/bugsink-bugsink.info.txt)
- [VERSION.txt](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/bugsink-bugsink/VERSION.txt)


Folder page: [https://github.com/Big13ang/ir-docker-image-downloder-by-mba/tree/master/docker-images/bugsink-bugsink](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/tree/master/docker-images/bugsink-bugsink)

## فهرست مطالب

- [مشخصات image](#مشخصات-image)
- [لینک فایل‌ها](#لینک-فایلها)
- [ابزارهای مورد نیاز](#ابزارهای-مورد-نیاز)
- [Linux / macOS](#linux--macos)
- [Windows PowerShell](#windows-powershell)
- [SHA256 یعنی چه؟](#sha256-یعنی-چه)
- [حمایت از پروژه](#حمایت-از-پروژه)

## مشخصات image

| مورد | مقدار |
| --- | --- |
| Docker image | `bugsink/bugsink` |
| Repository | `bugsink/bugsink` |
| Version type | `tag` |
| Version | `latest` |
| Output folder | `docker-images/bugsink-bugsink` |
| Archive file | `bugsink-bugsink.tar.zst` |
| Compression | `zstd` |
| Split | `true` |
| Part count | `2` |

نسخه و جزئیات image داخل فایل [VERSION.txt](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/bugsink-bugsink/VERSION.txt) هم ذخیره شده است.

## ابزارهای مورد نیاز

همیشه Docker لازم است:

- Docker Desktop: https://www.docker.com/products/docker-desktop/
- Docker install docs: https://docs.docker.com/engine/install/

برای این backup ابزار زیر هم لازم است:

- Required compression tool: `zstd`
- Download page: https://github.com/facebook/zstd/releases

اگر با خطایی مثل `zstd: command not found` یا `xz: command not found` روبه‌رو شدید، یعنی ابزار مربوطه نصب نیست.

## Linux / macOS

### 1. نصب ابزارها

Ubuntu/Debian:

```bash
sudo apt update && sudo apt install -y docker.io zstd
```

macOS:

```bash
brew install zstd
```

### 2. دانلود فایل‌ها

```bash
mkdir -p bugsink-bugsink
cd bugsink-bugsink
curl -L -o bugsink-bugsink.tar.zst.part-000 https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/bugsink-bugsink/bugsink-bugsink.tar.zst.part-000
curl -L -o bugsink-bugsink.tar.zst.part-001 https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/bugsink-bugsink/bugsink-bugsink.tar.zst.part-001

curl -L -o bugsink-bugsink.sha256 https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/bugsink-bugsink/bugsink-bugsink.sha256
```

### 3. بررسی سالم بودن دانلود

```bash
sha256sum -c bugsink-bugsink.sha256
```

### 4. ساخت archive اصلی از قطعه‌ها

```bash
cat bugsink-bugsink.tar.zst.part-* > bugsink-bugsink.tar.zst
```

### 5. Load داخل Docker

```bash
zstd -d -c bugsink-bugsink.tar.zst | docker load
```

### 6. بررسی نتیجه

```bash
docker images
```

## Windows PowerShell

### 1. نصب ابزارها

Docker Desktop:

https://www.docker.com/products/docker-desktop/

Compression tool:

https://github.com/facebook/zstd/releases

اگر Chocolatey دارید:

```powershell
choco install zstd
```

### 2. دانلود فایل‌ها

```powershell
New-Item -ItemType Directory -Force bugsink-bugsink
Set-Location bugsink-bugsink
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/bugsink-bugsink/bugsink-bugsink.tar.zst.part-000" -OutFile "bugsink-bugsink.tar.zst.part-000"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/bugsink-bugsink/bugsink-bugsink.tar.zst.part-001" -OutFile "bugsink-bugsink.tar.zst.part-001"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/bugsink-bugsink/bugsink-bugsink.sha256" -OutFile "bugsink-bugsink.sha256"
```

### 3. بررسی SHA256

PowerShell روی Windows به صورت پیش‌فرض فایل sha256sum لینوکسی را مستقیم نمی‌خواند. برای بررسی دستی، hash هر فایل را با مقدار داخل `bugsink-bugsink.sha256` مقایسه کنید:

```powershell
Get-FileHash -Algorithm SHA256 bugsink-bugsink.tar.zst.part-*
```

### 4. ساخت archive اصلی از قطعه‌ها

```powershell
$out = [System.IO.File]::Create("bugsink-bugsink.tar.zst")
Get-ChildItem -Filter "bugsink-bugsink.tar.zst.part-*" | Sort-Object Name | ForEach-Object {
    $in = [System.IO.File]::OpenRead($_.FullName)
    try { $in.CopyTo($out) } finally { $in.Close() }
}
$out.Close()
```

### 5. Load داخل Docker

```powershell
zstd -d -c bugsink-bugsink.tar.zst | docker load
```

### 6. بررسی نتیجه

```powershell
docker images
```

## SHA256 یعنی چه؟

فایل `bugsink-bugsink.sha256` برای این است که مطمئن شوید فایل‌هایی که دانلود کرده‌اید سالم، کامل و همان فایل‌هایی هستند که GitHub Action ساخته است.

این checksum نشان می‌دهد قطعه‌های archive بعد از ساخته شدن تغییری نکرده‌اند و دانلود شما ناقص یا خراب نیست.

نکته مهم: SHA256 اینجا برای فایل‌های backup داخل repo است، نه تایید امنیتی جداگانه درباره source image در Docker Hub.

## حمایت از پروژه

بزرگ‌ترین حمایت از ما معرفی و منتشر کردن این پروژه است. اگر این backup به شما کمک کرد، لطفا Docker Image Saver را به برنامه‌نویسان، تیم‌ها و شرکت‌هایی که با محدودیت Docker Hub یا registryها مشکل دارند معرفی کنید.

همچنین می‌توانید با Star دادن، Fork کردن، ثبت Issue، ارسال Pull Request یا حمایت مالی به بهتر شدن این ابزار کمک کنید.

### Donate

آدرس‌ها به ترتیب پیشنهادی قرار گرفته‌اند: اول شبکه‌های کم‌هزینه‌تر، و بین گزینه‌ها اولویت با USDT است.

#### USDT TRC20 (Tron) - پیشنهادی

```text
TRNfUz3zXsJYDQMYG5zxDseX3MSFxx8bxr
```

#### USDT SPL (Solana)

```text
FcCT54fD8A3VQ7nqNNf4kZprgCjdEFrJ7BSQBDb7i13i
```

#### USDT BEP20 (BNB Smart Chain)

```text
0x1126A4023F4EC18CfeF036C71e94F5D7D6D0902B
```

#### TON

```text
UQCvY7I4ROxsYOldjfRR-QnjiwdMlCsMA6Jw2tu2lRLDx6BC
```

#### TRX / Tron

```text
TRNfUz3zXsJYDQMYG5zxDseX3MSFxx8bxr
```

#### BNB

```text
0x1126A4023F4EC18CfeF036C71e94F5D7D6D0902B
```

#### BTC

```text
bc1qnhjk9zqmpg3wytw47luy8qsu2jhwpz83ll265k
```

ساخته شده با `Docker Image Saver` از تیم `اپ ساز`.

وب‌سایت اپ ساز: https://appsaz.ir

برنامه‌نویس پروژه: `محمد بهشت آئین`

Generated at: `2026-05-11T18:44:35Z`
