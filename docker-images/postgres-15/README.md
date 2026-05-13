# Docker image backup: `postgres:15`

این فولدر برای این ساخته شده که بازیابی این Docker image تا جای ممکن ساده و بی‌دردسر باشد؛ مخصوصا وقتی سیستم مقصد به Docker Hub یا registry اصلی دسترسی راحتی ندارد.

## لینک فایل‌ها

- [postgres-15.tar.part-000](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/postgres-15/postgres-15.tar.part-000)
- [postgres-15.tar.part-001](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/postgres-15/postgres-15.tar.part-001)
- [postgres-15.tar.part-002](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/postgres-15/postgres-15.tar.part-002)
- [postgres-15.tar.part-003](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/postgres-15/postgres-15.tar.part-003)
- [postgres-15.tar.part-004](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/postgres-15/postgres-15.tar.part-004)
- [postgres-15.manifest.json](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/postgres-15/postgres-15.manifest.json)
- [postgres-15.sha256](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/postgres-15/postgres-15.sha256)
- [postgres-15.info.txt](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/postgres-15/postgres-15.info.txt)
- [VERSION.txt](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/postgres-15/VERSION.txt)


Folder page: [https://github.com/Big13ang/ir-docker-image-downloder-by-mba/tree/master/docker-images/postgres-15](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/tree/master/docker-images/postgres-15)

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
| Docker image | `postgres:15` |
| Repository | `postgres` |
| Version type | `tag` |
| Version | `15` |
| Platform | `linux/amd64` |
| Output folder | `docker-images/postgres-15` |
| Archive file | `postgres-15.tar` |
| Compression | `none` |
| Split | `true` |
| Part count | `5` |

نسخه و جزئیات image داخل فایل [VERSION.txt](https://github.com/Big13ang/ir-docker-image-downloder-by-mba/blob/master/docker-images/postgres-15/VERSION.txt) هم ذخیره شده است.

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
mkdir -p postgres-15
cd postgres-15
curl -L -o postgres-15.tar.part-000 https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/postgres-15/postgres-15.tar.part-000
curl -L -o postgres-15.tar.part-001 https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/postgres-15/postgres-15.tar.part-001
curl -L -o postgres-15.tar.part-002 https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/postgres-15/postgres-15.tar.part-002
curl -L -o postgres-15.tar.part-003 https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/postgres-15/postgres-15.tar.part-003
curl -L -o postgres-15.tar.part-004 https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/postgres-15/postgres-15.tar.part-004

curl -L -o postgres-15.sha256 https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/postgres-15/postgres-15.sha256
```

### 3. بررسی سالم بودن دانلود

```bash
sha256sum -c postgres-15.sha256
```

### 4. ساخت archive اصلی از قطعه‌ها

```bash
cat postgres-15.tar.part-* > postgres-15.tar
```

### 5. Load داخل Docker

```bash
docker load -i postgres-15.tar
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
New-Item -ItemType Directory -Force postgres-15
Set-Location postgres-15
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/postgres-15/postgres-15.tar.part-000" -OutFile "postgres-15.tar.part-000"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/postgres-15/postgres-15.tar.part-001" -OutFile "postgres-15.tar.part-001"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/postgres-15/postgres-15.tar.part-002" -OutFile "postgres-15.tar.part-002"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/postgres-15/postgres-15.tar.part-003" -OutFile "postgres-15.tar.part-003"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/postgres-15/postgres-15.tar.part-004" -OutFile "postgres-15.tar.part-004"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Big13ang/ir-docker-image-downloder-by-mba/master/docker-images/postgres-15/postgres-15.sha256" -OutFile "postgres-15.sha256"
```

### 3. بررسی SHA256

PowerShell روی Windows به صورت پیش‌فرض فایل sha256sum لینوکسی را مستقیم نمی‌خواند. برای بررسی دستی، hash هر فایل را با مقدار داخل `postgres-15.sha256` مقایسه کنید:

```powershell
Get-FileHash -Algorithm SHA256 postgres-15.tar.part-*
```

### 4. ساخت archive اصلی از قطعه‌ها

```powershell
$out = [System.IO.File]::Create("postgres-15.tar")
Get-ChildItem -Filter "postgres-15.tar.part-*" | Sort-Object Name | ForEach-Object {
    $in = [System.IO.File]::OpenRead($_.FullName)
    try { $in.CopyTo($out) } finally { $in.Close() }
}
$out.Close()
```

### 5. Load داخل Docker

```powershell
docker load -i postgres-15.tar
```

### 6. بررسی نتیجه

```powershell
docker images
```

## SHA256 یعنی چه؟

فایل `postgres-15.sha256` برای این است که مطمئن شوید فایل‌هایی که دانلود کرده‌اید سالم، کامل و همان فایل‌هایی هستند که GitHub Action ساخته است.

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

Generated at: `2026-05-13T13:38:11Z`
