# Docker image backup: `ghcr.io/big13ang/inshop-pre-registration-back-end:sha-437ac36`

این فولدر برای این ساخته شده که بازیابی این Docker image تا جای ممکن ساده و بی‌دردسر باشد؛ مخصوصا وقتی سیستم مقصد به Docker Hub یا registry اصلی دسترسی راحتی ندارد.

## لینک فایل‌ها

- [inshop-back-end-part-000.tar](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-000.tar)
- [inshop-back-end-part-001.tar](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-001.tar)
- [inshop-back-end-part-002.tar](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-002.tar)
- [inshop-back-end-part-003.tar](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-003.tar)
- [inshop-back-end-part-004.tar](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-004.tar)
- [inshop-back-end-part-005.tar](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-005.tar)
- [inshop-back-end-part-006.tar](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-006.tar)
- [inshop-back-end-part-007.tar](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-007.tar)
- [inshop-back-end-part-008.tar](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-008.tar)
- [inshop-back-end-part-009.tar](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-009.tar)
- [inshop-back-end-part-010.tar](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-010.tar)
- [inshop-back-end.manifest.json](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end.manifest.json)
- [inshop-back-end.sha256](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end.sha256)
- [inshop-back-end.info.txt](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end.info.txt)
- [VERSION.txt](https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/VERSION.txt)


Important: the links above are direct raw download links. If a downloaded
`.part-*` file is only a few hundred KB instead of about 95MB,
you probably saved the GitHub HTML page, not the Docker image chunk. Re-download
with the Linux/macOS or Windows commands below.

Folder page: [https://github.com/Big13ang/ir-docker-image-downloder-by-mba/tree/master/docker-images/inshop-back-end](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/tree/master/docker-images/inshop-back-end)

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
| Docker image | `ghcr.io/big13ang/inshop-pre-registration-back-end:sha-437ac36` |
| Repository | `ghcr.io/big13ang/inshop-pre-registration-back-end` |
| Version type | `tag` |
| Version | `sha-437ac36` |
| Platform | `linux/amd64` |
| Output folder | `docker-images/inshop-back-end` |
| Archive file | `inshop-back-end.tar` |
| Compression | `none` |
| Split | `true` |
| Part count | `11` |

نسخه و جزئیات image داخل فایل [VERSION.txt](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/inshop-back-end/VERSION.txt) هم ذخیره شده است.

## ابزارهای مورد نیاز

همیشه Docker لازم است:

- Docker Desktop: https://www.docker.com/products/docker-desktop/
- Docker install docs: https://docs.docker.com/engine/install/

برای این backup ابزار زیر هم لازم است:

- Required compression tool: `none`
- Download page: Not needed

اگر با خطایی مثل `zstd: command not found` یا `xz: command not found` روبه‌رو شدید، یعنی ابزار مربوطه نصب نیست.

## Linux / macOS

### 1. نصب ابزارها

Ubuntu/Debian:

```bash
sudo apt update && sudo apt install -y docker.io
```

macOS:

```bash
# Only Docker is required
```

### 2. دانلود فایل‌ها

```bash
mkdir -p inshop-back-end
cd inshop-back-end
curl -L -o inshop-back-end-part-000.tar https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-000.tar
curl -L -o inshop-back-end-part-001.tar https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-001.tar
curl -L -o inshop-back-end-part-002.tar https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-002.tar
curl -L -o inshop-back-end-part-003.tar https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-003.tar
curl -L -o inshop-back-end-part-004.tar https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-004.tar
curl -L -o inshop-back-end-part-005.tar https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-005.tar
curl -L -o inshop-back-end-part-006.tar https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-006.tar
curl -L -o inshop-back-end-part-007.tar https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-007.tar
curl -L -o inshop-back-end-part-008.tar https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-008.tar
curl -L -o inshop-back-end-part-009.tar https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-009.tar
curl -L -o inshop-back-end-part-010.tar https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-010.tar

curl -L -o inshop-back-end.sha256 https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end.sha256
```

### 3. بررسی سالم بودن دانلود

```bash
sha256sum -c inshop-back-end.sha256
```

### 4. ساخت archive اصلی از قطعه‌ها

```bash
cat inshop-back-end-part-*.tar > inshop-back-end.tar
```

### 5. Load داخل Docker

```bash
docker load -i inshop-back-end.tar
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

Not needed

اگر Chocolatey دارید:

```powershell
# Only Docker is required
```

### 2. دانلود فایل‌ها

```powershell
New-Item -ItemType Directory -Force inshop-back-end
Set-Location inshop-back-end
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-000.tar" -OutFile "inshop-back-end-part-000.tar"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-001.tar" -OutFile "inshop-back-end-part-001.tar"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-002.tar" -OutFile "inshop-back-end-part-002.tar"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-003.tar" -OutFile "inshop-back-end-part-003.tar"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-004.tar" -OutFile "inshop-back-end-part-004.tar"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-005.tar" -OutFile "inshop-back-end-part-005.tar"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-006.tar" -OutFile "inshop-back-end-part-006.tar"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-007.tar" -OutFile "inshop-back-end-part-007.tar"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-008.tar" -OutFile "inshop-back-end-part-008.tar"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-009.tar" -OutFile "inshop-back-end-part-009.tar"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end-part-010.tar" -OutFile "inshop-back-end-part-010.tar"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/inshop-back-end/inshop-back-end.sha256" -OutFile "inshop-back-end.sha256"
```

### 3. بررسی SHA256

PowerShell روی Windows به صورت پیش‌فرض فایل sha256sum لینوکسی را مستقیم نمی‌خواند. برای بررسی دستی، hash هر فایل را با مقدار داخل `inshop-back-end.sha256` مقایسه کنید:

```powershell
Get-FileHash -Algorithm SHA256 inshop-back-end-part-*.tar
```

### 4. ساخت archive اصلی از قطعه‌ها

```powershell
$out = [System.IO.File]::Create("inshop-back-end.tar")
Get-ChildItem -Filter "inshop-back-end-part-*.tar" | Sort-Object Name | ForEach-Object {
    $in = [System.IO.File]::OpenRead($_.FullName)
    try { $in.CopyTo($out) } finally { $in.Close() }
}
$out.Close()
```

### 5. Load داخل Docker

```powershell
docker load -i inshop-back-end.tar
```

### 6. بررسی نتیجه

```powershell
docker images
```

## SHA256 یعنی چه؟

فایل `inshop-back-end.sha256` برای این است که مطمئن شوید فایل‌هایی که دانلود کرده‌اید سالم، کامل و همان فایل‌هایی هستند که GitHub Action ساخته است.

این checksum نشان می‌دهد قطعه‌های archive بعد از ساخته شدن تغییری نکرده‌اند و دانلود شما ناقص یا خراب نیست.

نکته مهم: SHA256 اینجا برای فایل‌های backup داخل repo است، نه تایید امنیتی جداگانه درباره source image در Docker Hub.

## حمایت از پروژه

بزرگ‌ترین حمایت از ما معرفی و منتشر کردن این پروژه است. اگر این backup به شما کمک کرد، لطفا Docker Image Saver را به یک برنامه‌نویس، تیم یا شرکتی که با محدودیت Docker Hub یا registryها مشکل دارد معرفی کنید.

ما این ابزار را برای کم کردن فشار از روی تیم‌های فنی ساختیم. Star دادن، Fork کردن، ثبت Issue، ارسال Pull Request، معرفی پروژه و حمایت مالی، همه برای بهتر شدنش ارزشمندند.

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

ارادتمند، `بهشت آئین` از تیم `اپ ساز`

وب‌سایت اپ ساز: https://appsaz.ir

Generated at: `2026-05-16T11:51:03Z`
