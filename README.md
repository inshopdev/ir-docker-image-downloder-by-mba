# Docker Image Saver

یک ریپوی آماده برای گرفتن Docker image از Docker Hub یا هر registry دیگر، فشرده‌سازی آن، تقسیم فایل‌های بزرگ، و ذخیره خروجی داخل GitHub Repository یا GitHub Releases.

این پروژه برای جاهایی ساخته شده که دسترسی مستقیم به Docker Hub یا registry محدود است. یک بار image را با GitHub Actions می‌گیرید، خروجی را از GitHub دانلود می‌کنید، و روی سیستم مقصد با `docker load` برمی‌گردانید.

## قابلیت‌ها

- اجرای دستی از تب GitHub Actions
- دریافت هر image مثل `nginx:alpine` یا `ghcr.io/org/app:tag`
- فشرده‌سازی با `zstd`، `gzip`، `xz` یا بدون فشرده‌سازی
- تقسیم خودکار فایل‌های بزرگ به قطعات کوچک‌تر
- تولید `manifest.json`، checksum و گزارش فشرده‌سازی
- پشتیبانی از Git LFS برای ذخیره فایل‌های حجیم داخل repo
- ساخت فایل ZIP آماده برای GitHub Releases
- اسکریپت restore برای Linux، macOS و Windows PowerShell

## شروع سریع

1. این repo را در GitHub بسازید یا fork کنید.
2. از تب `Actions` workflow با نام `Save Docker Image` را باز کنید.
3. روی `Run workflow` بزنید.
4. مقدار `Docker image` را وارد کنید. این باید اسم واقعی Docker image باشد، نه اسم فولدر خروجی.

```text
nginx:alpine
```

مثال دیگر:

```text
bugsink/bugsink
```

اگر `bugsink-bugsink` وارد کنید Docker دنبال imageای با همین اسم می‌گردد و خطای `pull access denied` می‌دهد. `bugsink-bugsink` فقط اسم فولدری است که این ابزار برای خروجی می‌سازد.

5. workflow را اجرا کنید.
6. بعد از اتمام، به پوشه `docker-images/<image-name>/` بروید.
7. فایل `README.md` همان پوشه را باز کنید. داخلش لینک دانلود فایل‌ها و دستورهای مرحله‌ای همان image آماده است.

نمونه مسیر:

```text
docker-images/bugsink-bugsink/README.md
```

اگر کل repo را clone کرده‌اید، می‌توانید یکی از restore scriptها را اجرا کنید.

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

## ورودی‌های workflow

| Input | توضیح | پیش‌فرض |
| --- | --- | --- |
| `image` | نام Docker image مثل `nginx:alpine` | اجباری |
| `output_name` | نام خروجی. اگر خالی باشد از نام image ساخته می‌شود | خالی |
| `compression` | نوع فشرده‌سازی: `zstd`, `gzip`, `xz`, `none` | `zstd` |
| `zstd_level` | سطح فشرده‌سازی zstd از 1 تا 19 | `10` |
| `split_size_mb` | اندازه هر قطعه برای split شدن. برای ذخیره مستقیم در repo زیر 100 نگه دارید | `95` |
| `commit_to_repo` | خروجی داخل branch فعلی commit شود | `true` |
| `create_release` | فایل ZIP در GitHub Releases منتشر شود | `false` |

## ساختار خروجی

```text
docker-backup-nginx-alpine.zip
├── README.md
├── QUICK_START.md
├── docker-images/
│   └── nginx-alpine/
│       ├── README.md
│       ├── nginx-alpine.part-001
│       ├── nginx-alpine.part-002
│       ├── nginx-alpine.manifest.json
│       ├── nginx-alpine.sha256
│       └── nginx-alpine.info.txt
└── scripts/
    ├── restore-linux.sh
    ├── restore-mac.sh
    └── restore-windows.ps1
```

اگر فایل کوچک باشد، به جای `.part-*` یک فایل مثل `docker-images/nginx-alpine/nginx-alpine.tar.zst` ساخته می‌شود.

## استفاده محلی

اگر می‌خواهید روی سیستم خودتان image را backup بگیرید:

```bash
chmod +x scripts/save-image.sh
./scripts/save-image.sh nginx:alpine
```

برای تنظیمات بیشتر:

```bash
COMPRESSION=zstd ZSTD_LEVEL=12 SPLIT_SIZE_MB=1000 ./scripts/save-image.sh nginx:alpine my-nginx
```

## نکته درباره محدودیت GitHub

برای اینکه فایل‌ها مثل `docker-images/name/name.tar.zst` مستقیما داخل codebase دیده شوند، این repo از Git LFS برای imageها استفاده نمی‌کند. GitHub فایل‌های بزرگ‌تر از 100MB را در git معمولی reject می‌کند، پس مقدار `split_size_mb` را زیر 100 نگه دارید. پیش‌فرض پروژه `95` است.

اگر image خیلی بزرگ است، workflow آن را به چند فایل `.part-*` تقسیم می‌کند تا همه قطعه‌ها داخل `docker-images/<image-name>/` commit شوند و URL آن‌ها از نوع معمولی `github.com/.../blob/...` باشد، نه `media.githubusercontent.com`.

## بازیابی دستی

بهترین راه اجرای restore script است. اگر دستی می‌خواهید:

```bash
# split + zstd
cat docker-images/name/name.part-* | zstd -d -c | docker load

# zstd تک‌فایل
zstd -d -c docker-images/name/name.tar.zst | docker load

# gzip تک‌فایل
gunzip -c docker-images/name/name.tar.gz | docker load

# xz تک‌فایل
xz -d -c docker-images/name/name.tar.xz | docker load

# tar بدون فشرده‌سازی
docker load -i docker-images/name/name.tar
```

## نوشته شده توسط MBA

این پروژه برای ساختن یک مسیر ساده، قابل fork و قابل استفاده برای انتقال Docker image از طریق GitHub ساخته شده است.
