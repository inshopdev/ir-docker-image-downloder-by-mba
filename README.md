# Docker Image Saver

Docker Image Saver یک ابزار ساده و کاربردی برای ذخیره کردن Docker imageها داخل GitHub Repository است؛ برای وقت‌هایی که دسترسی مستقیم به Docker Hub یا registryها سخت، کند یا محدود شده.

ما در تیم **اپ ساز** این پروژه را با یک دغدغه واقعی ساختیم: کمک به برنامه‌نویس‌ها، تیم‌های فنی و شرکت‌هایی که به خاطر فیلترینگ، محدودیت‌های دسترسی و فشار اقتصادی، حتی برای گرفتن یک Docker image ساده هم وقت و انرژی زیادی از دست می‌دهند.

وب‌سایت اپ ساز: https://appsaz.ir

امید ما این است که این ابزار، حتی کمی، کار deploy و نگهداری سرویس‌ها را راحت‌تر کند و از فشار روزمره روی تیم‌های ایرانی کم کند. شما image را یک بار با GitHub Actions ذخیره می‌کنید، بعد هر وقت لازم داشتید از خود GitHub دانلودش می‌کنید و با `docker load` برمی‌گردانید.

## فهرست مطالب

- [این پروژه چه کاری می‌کند؟](#این-پروژه-چه-کاری-میکند)
- [شروع سریع](#شروع-سریع)
- [ساختار خروجی](#ساختار-خروجی)
- [راهنمای دانلود و بازیابی](#راهنمای-دانلود-و-بازیابی)
- [ابزارهای مورد نیاز](#ابزارهای-مورد-نیاز)
- [SHA256 یعنی چه؟](#sha256-یعنی-چه)
- [ورودی‌های workflow](#ورودیهای-workflow)
- [محدودیت‌های GitHub](#محدودیتهای-github)
- [استفاده محلی](#استفاده-محلی)
- [حمایت و مشارکت](#حمایت-و-مشارکت)
- [ارادتمند](#ارادتمند)

## این پروژه چه کاری می‌کند؟

- یک Docker image مثل `nginx:alpine` یا `bugsink/bugsink` را pull می‌کند.
- image را با `docker save` به فایل tar تبدیل می‌کند.
- به شما اجازه می‌دهد platform مورد نظر را انتخاب کنید، مثلا `linux/amd64` یا `linux/arm64`.
- در حالت پیش‌فرض فایل را بدون فشرده‌سازی ذخیره می‌کند تا برای بازیابی به ابزار اضافه‌ای غیر از Docker نیاز نباشد.
- اگر خواستید، می‌توانید فایل را با `zstd`، `gzip` یا `xz` هم فشرده کنید.
- اگر فایل بزرگ باشد، آن را به قطعه‌های کوچک‌تر از 100MB تقسیم می‌کند.
- فایل‌ها را داخل مسیر اختصاصی همان image ذخیره می‌کند.
- برای هر image یک `README.md` اختصاصی می‌سازد که لینک دانلود، checksum، extract و `docker load` را مرحله‌به‌مرحله توضیح می‌دهد.

## شروع سریع

1. این repo را fork کنید یا repo خودتان را از روی آن بسازید.
2. وارد تب **Actions** شوید.
3. workflow با نام **Save Docker Image** را باز کنید.
4. روی **Run workflow** بزنید.
5. در فیلد `Docker image` اسم واقعی image را وارد کنید.

مثال درست:

```text
bugsink/bugsink
```

مثال اشتباه:

```text
bugsink-bugsink
```

`bugsink-bugsink` فقط اسم فولدر خروجی است. Docker image واقعی معمولا با `/` نوشته می‌شود، مثل `bugsink/bugsink`.

بعد از اجرای workflow، خروجی را اینجا می‌بینید:

```text
docker-images/<image-name>/
```

مثلا:

```text
docker-images/bugsink-bugsink/
```

اول فایل زیر را باز کنید:

```text
docker-images/bugsink-bugsink/README.md
```

همان فایل، راهنمای دقیق دانلود و بازیابی همان image است.

## ساختار خروجی

```text
docker-images/
└── bugsink-bugsink/
    ├── README.md
    ├── VERSION.txt
    ├── bugsink-bugsink.tar.part-000
    ├── bugsink-bugsink.tar.part-001
    ├── bugsink-bugsink.manifest.json
    ├── bugsink-bugsink.sha256
    └── bugsink-bugsink.info.txt
```

اگر فایل کوچک باشد، به جای فایل‌های `.part-*` یک فایل archive کامل ساخته می‌شود:

```text
docker-images/nginx-alpine/nginx-alpine.tar
```

## راهنمای دانلود و بازیابی

هر فولدر image یک `README.md` اختصاصی دارد. آن فایل شامل این بخش‌هاست:

1. لینک مستقیم فایل‌ها
2. ابزارهای مورد نیاز با لینک دانلود
3. دستور دانلود برای Linux/macOS
4. دستور دانلود برای Windows PowerShell
5. دستور بررسی SHA256
6. دستور اتصال قطعه‌ها به archive اصلی
7. دستور load کردن داخل Docker
8. دستور بررسی موفقیت با `docker images`

برای clone کامل repo هم می‌توانید از اسکریپت‌ها استفاده کنید:

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

## ابزارهای مورد نیاز

برای بازیابی image همیشه Docker لازم است:

- Docker Desktop: https://www.docker.com/products/docker-desktop/
- Docker installation docs: https://docs.docker.com/engine/install/

در حالت پیش‌فرض فقط Docker کافی است. اگر compression را از `none` به یکی از گزینه‌های دیگر تغییر دهید، یکی از ابزارهای زیر هم لازم می‌شود:

- zstd: https://github.com/facebook/zstd/releases
- XZ Utils: https://tukaani.org/xz/
- gzip for Windows: https://gnuwin32.sourceforge.net/packages/gzip.htm

نصب سریع روی Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y zstd gzip xz-utils
```

نصب سریع روی macOS با Homebrew:

```bash
brew install zstd xz
```

نصب سریع روی Windows با Chocolatey:

```powershell
choco install zstd gzip xz
```

## SHA256 یعنی چه؟

فایل `.sha256` برای این است که شما بتوانید بررسی کنید فایل‌ها درست و کامل دانلود شده‌اند.

همچنین کمک می‌کند مطمئن شوید همان فایل‌هایی را دارید که GitHub Action ساخته و بعد از ساخت archive، تغییری در قطعه‌ها ایجاد نشده است.

نکته مهم: این checksum برای فایل‌های backup داخل repo است. یعنی سلامت دانلود و یکسان بودن قطعه‌های archive را بررسی می‌کند، نه اینکه درباره امنیت image اصلی در Docker Hub ادعای جداگانه‌ای داشته باشد.

## ورودی‌های workflow

| Input | توضیح | پیش‌فرض |
| --- | --- | --- |
| `image` | اسم واقعی Docker image مثل `nginx:alpine` یا `bugsink/bugsink` | اجباری |
| `output_name` | اسم فولدر خروجی. اگر خالی باشد از نام image ساخته می‌شود | خالی |
| `platform` | معماری/سیستم‌عامل image مثل `linux/amd64`, `linux/arm64`, `linux/arm/v7` | `linux/amd64` |
| `compression` | نوع فشرده‌سازی: `none`, `zstd`, `gzip`, `xz` | `none` |
| `zstd_level` | سطح فشرده‌سازی zstd از 1 تا 19 | `10` |
| `split_size_mb` | اندازه هر قطعه. برای GitHub زیر 100 نگه دارید | `95` |
| `commit_to_repo` | خروجی داخل همین repo commit شود | `true` |
| `create_release` | فایل ZIP در GitHub Releases ساخته شود | `false` |

## محدودیت‌های GitHub

GitHub فایل‌های بزرگ‌تر از 100MB را در git معمولی reject می‌کند. برای اینکه فایل‌ها به صورت عادی داخل codebase و زیر URLهای `github.com/.../blob/...` دیده شوند، این پروژه فایل‌های بزرگ را split می‌کند.

نام قطعه‌ها واضح است:

```text
bugsink-bugsink.tar.part-000
bugsink-bugsink.tar.part-001
```

یعنی در حالت پیش‌فرض باید قطعه‌ها به `bugsink-bugsink.tar` تبدیل شوند و بعد مستقیم با Docker load شوند.

## استفاده محلی

```bash
chmod +x scripts/save-image.sh
./scripts/save-image.sh nginx:alpine
```

با تنظیمات بیشتر:

```bash
PLATFORM=linux/arm64 COMPRESSION=none SPLIT_SIZE_MB=95 ./scripts/save-image.sh nginx:alpine
```

## حمایت و مشارکت

بزرگ‌ترین حمایت از ما، معرفی و منتشر کردن این پروژه است. اگر این ابزار به درد شما خورد، لطفا آن را به یک نفر دیگر هم معرفی کنید؛ شاید همان معرفی ساده، چند ساعت از وقت یک تیم را نجات بدهد.

ما این پروژه را برای کمک به برنامه‌نویس‌ها و شرکت‌هایی ساختیم که در شرایط سخت فعلی، با محدودیت‌های دسترسی، هزینه‌ها و فشار کاری دست‌وپنجه نرم می‌کنند. اگر این مسیر برای شما مفید بود، خوشحال می‌شویم کمک کنید به دست کسانی برسد که واقعا به آن نیاز دارند.

راه‌های حمایت از پروژه:

- معرفی پروژه به دیگر برنامه‌نویسان و شرکت‌ها
- Star دادن به repo در GitHub
- Fork کردن پروژه و ساخت نسخه مناسب نیازهای خودتان
- ثبت Issue برای گزارش مشکل یا پیشنهاد قابلیت جدید
- ارسال Pull Request برای بهتر شدن ابزار
- حمایت مالی برای توسعه سریع‌تر قابلیت‌های جدید

ما از حمایت فنی، مالی و از همه مهم‌تر، از پخش شدن این ابزار بین جامعه برنامه‌نویسان استقبال می‌کنیم.

### درخواست قابلیت جدید

اگر قابلیت خاصی نیاز دارید، می‌توانید Issue ثبت کنید، پروژه را fork کنید و Pull Request بفرستید، یا برای پیاده‌سازی سریع‌تر آن از توسعه پروژه حمایت مالی کنید.

ما تلاش می‌کنیم قابلیت‌هایی را در اولویت قرار دهیم که بیشترین کمک را به برنامه‌نویسان و شرکت‌های ایرانی می‌کنند.

### حمایت مالی

این پروژه رایگان است و رایگان هم می‌ماند، اما نگهداری و بهتر کردنش زمان و انرژی می‌خواهد. اگر این ابزار به کارتان کمک کرد، یا دوست دارید قابلیت تازه‌ای به آن اضافه شود، حمایت مالی شما می‌تواند کمک کند با دلگرمی بیشتری ادامه بدهیم.

برای راحتی، آدرس‌ها به ترتیب پیشنهادی قرار گرفته‌اند: اول شبکه‌های کم‌هزینه‌تر، و بین گزینه‌ها اولویت با USDT است.

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

## ارادتمند

ارادتمند، **بهشت آئین** از تیم **اپ ساز**<br>
https://appsaz.ir
