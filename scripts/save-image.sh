#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-}"
OUTPUT_NAME="${2:-}"
COMPRESSION="${COMPRESSION:-none}"
PLATFORM="${PLATFORM:-linux/amd64}"
ZSTD_LEVEL="${ZSTD_LEVEL:-10}"
SPLIT_SIZE_MB="${SPLIT_SIZE_MB:-95}"
OUTPUT_ROOT="${OUTPUT_DIR:-docker-images}"
REPOSITORY="${GITHUB_REPOSITORY:-OWNER/REPO}"
BRANCH="${GITHUB_REF_NAME:-master}"
PROJECT_NAME="Docker Image Saver"
PROJECT_TEAM="اپ ساز"
PROJECT_WEBSITE="https://appsaz.ir"

if [ -z "$IMAGE" ]; then
  echo "Usage: $0 <docker-image> [output-name]"
  echo "Example: $0 nginx:alpine nginx-alpine"
  exit 1
fi

command -v docker >/dev/null 2>&1 || { echo "docker is required"; exit 1; }

if ! [[ "$IMAGE" =~ ^[A-Za-z0-9._/@:-]+$ ]]; then
  echo "Invalid Docker image name: $IMAGE"
  echo "Allowed characters: letters, numbers, dot, underscore, slash, colon, at-sign, and dash."
  exit 1
fi

if ! [[ "$PLATFORM" =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+(/[A-Za-z0-9._-]+)?$ ]]; then
  echo "Invalid platform: $PLATFORM"
  echo "Use a Docker platform like linux/amd64, linux/arm64, or linux/arm/v7."
  exit 1
fi

if ! [[ "$SPLIT_SIZE_MB" =~ ^[0-9]+$ ]] || [ "$SPLIT_SIZE_MB" -lt 1 ]; then
  echo "SPLIT_SIZE_MB must be a positive number."
  exit 1
fi

if ! [[ "$ZSTD_LEVEL" =~ ^[0-9]+$ ]] || [ "$ZSTD_LEVEL" -lt 1 ] || [ "$ZSTD_LEVEL" -gt 19 ]; then
  echo "ZSTD_LEVEL must be a number between 1 and 19."
  exit 1
fi

safe_name() {
  printf '%s' "$1" \
    | tr '/:@' '---' \
    | tr -cs 'A-Za-z0-9._-' '-' \
    | sed 's/^-//; s/-$//'
}

if [ -z "$OUTPUT_NAME" ]; then
  OUTPUT_NAME="$(safe_name "$IMAGE")"
else
  OUTPUT_NAME="$(safe_name "$OUTPUT_NAME")"
fi

if [ -z "$OUTPUT_NAME" ]; then
  echo "Output name is empty after sanitizing. Use a Docker image name like nginx:alpine."
  exit 1
fi

if [[ "$IMAGE" == *@* ]]; then
  IMAGE_REPOSITORY="${IMAGE%@*}"
  IMAGE_VERSION="${IMAGE#*@}"
  IMAGE_VERSION_KIND="digest"
else
  LAST_IMAGE_PART="${IMAGE##*/}"
  if [[ "$LAST_IMAGE_PART" == *:* ]]; then
    IMAGE_REPOSITORY="${IMAGE%:*}"
    IMAGE_VERSION="${LAST_IMAGE_PART##*:}"
  else
    IMAGE_REPOSITORY="$IMAGE"
    IMAGE_VERSION="latest"
  fi
  IMAGE_VERSION_KIND="tag"
fi

OUTPUT_DIR="${OUTPUT_ROOT}/${OUTPUT_NAME}"
mkdir -p "$OUTPUT_DIR" .tmp
rm -f "${OUTPUT_DIR}/${OUTPUT_NAME}"* "${OUTPUT_DIR}/README.md" "${OUTPUT_DIR}/VERSION.txt"

RAW_TAR=".tmp/${OUTPUT_NAME}.tar"
BASE="${OUTPUT_DIR}/${OUTPUT_NAME}"
START_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "Pulling image: $IMAGE"
echo "Platform: $PLATFORM"
if ! docker pull --platform "$PLATFORM" "$IMAGE"; then
  echo ""
  echo "Docker could not pull: $IMAGE"
  echo "Platform: $PLATFORM"
  echo ""
  echo "Use the real Docker image name in the workflow input."
  echo "Examples:"
  echo "  nginx:alpine"
  echo "  bugsink/bugsink"
  echo "  ghcr.io/owner/image:tag"
  echo ""
  echo "If the image exists but this still fails, the selected platform may not be available for that image."
  echo "Try another platform such as linux/amd64 or linux/arm64."
  echo ""
  echo "Do not put the generated folder name as the image name."
  echo "For example, use 'bugsink/bugsink' as the image and let this tool create the folder 'bugsink-bugsink'."
  exit 1
fi

echo "Saving Docker image to tar"
docker save "$IMAGE" -o "$RAW_TAR"

IMAGE_ID="$(docker image inspect "$IMAGE" --format '{{.Id}}' 2>/dev/null || true)"
IMAGE_DIGESTS="$(docker image inspect "$IMAGE" --format '{{range .RepoDigests}}{{println .}}{{end}}' 2>/dev/null | sed '/^$/d' || true)"

RAW_SIZE="$(wc -c < "$RAW_TAR" | tr -d ' ')"

case "$COMPRESSION" in
  zstd)
    command -v zstd >/dev/null 2>&1 || { echo "zstd is required"; exit 1; }
    OUT_FILE="${BASE}.tar.zst"
    echo "Compressing with zstd level ${ZSTD_LEVEL}"
    zstd -T0 -"${ZSTD_LEVEL}" -f "$RAW_TAR" -o "$OUT_FILE"
    ;;
  gzip)
    OUT_FILE="${BASE}.tar.gz"
    if command -v pigz >/dev/null 2>&1; then
      echo "Compressing with pigz"
      pigz -c "$RAW_TAR" > "$OUT_FILE"
    else
      echo "Compressing with gzip"
      gzip -c "$RAW_TAR" > "$OUT_FILE"
    fi
    ;;
  xz)
    command -v xz >/dev/null 2>&1 || { echo "xz is required"; exit 1; }
    OUT_FILE="${BASE}.tar.xz"
    echo "Compressing with xz"
    xz -T0 -c "$RAW_TAR" > "$OUT_FILE"
    ;;
  none)
    OUT_FILE="${BASE}.tar"
    echo "Keeping uncompressed tar"
    mv "$RAW_TAR" "$OUT_FILE"
    ;;
  *)
    echo "Unsupported compression: $COMPRESSION"
    exit 1
    ;;
esac

if [ -f "$RAW_TAR" ]; then
  rm -f "$RAW_TAR"
fi

COMPRESSED_SIZE="$(wc -c < "$OUT_FILE" | tr -d ' ')"
ARCHIVE_FILE="$(basename "$OUT_FILE")"
SPLIT_SIZE_BYTES=$((SPLIT_SIZE_MB * 1024 * 1024))
SPLIT=false
PART_COUNT=0

if [ "$COMPRESSED_SIZE" -gt "$SPLIT_SIZE_BYTES" ]; then
  echo "Splitting into ${SPLIT_SIZE_MB}MB parts"
  split -b "${SPLIT_SIZE_MB}M" -d -a 3 "$OUT_FILE" "${OUT_FILE}.part-"
  rm -f "$OUT_FILE"
  SPLIT=true
  PART_COUNT="$(find "$OUTPUT_DIR" -maxdepth 1 -type f -name "${ARCHIVE_FILE}.part-*" | wc -l | tr -d ' ')"
fi

SHA_FILE="${BASE}.sha256"
if [ "$SPLIT" = true ]; then
  (cd "$OUTPUT_DIR" && sha256sum "${ARCHIVE_FILE}".part-* > "${OUTPUT_NAME}.sha256")
else
  (cd "$OUTPUT_DIR" && sha256sum "$ARCHIVE_FILE" > "${OUTPUT_NAME}.sha256")
fi

END_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
INFO_FILE="${BASE}.info.txt"
MANIFEST_FILE="${BASE}.manifest.json"
README_FILE="${OUTPUT_DIR}/README.md"
VERSION_FILE="${OUTPUT_DIR}/VERSION.txt"

cat > "$INFO_FILE" <<EOF
Image: $IMAGE
Repository: $IMAGE_REPOSITORY
Version type: $IMAGE_VERSION_KIND
Version: $IMAGE_VERSION
Platform: $PLATFORM
Image ID: $IMAGE_ID
Output name: $OUTPUT_NAME
Compression: $COMPRESSION
Archive file: $ARCHIVE_FILE
Raw tar size: $RAW_SIZE bytes
Stored size: $COMPRESSED_SIZE bytes
Split: $SPLIT
Part count: $PART_COUNT
Started: $START_TIME
Finished: $END_TIME
EOF

{
  echo "Image: $IMAGE"
  echo "Repository: $IMAGE_REPOSITORY"
  echo "Version type: $IMAGE_VERSION_KIND"
  echo "Version: $IMAGE_VERSION"
  echo "Platform: $PLATFORM"
  echo "Image ID: $IMAGE_ID"
  if [ -n "$IMAGE_DIGESTS" ]; then
    echo "Repo digests:"
    printf '%s\n' "$IMAGE_DIGESTS"
  fi
  echo "Created at: $END_TIME"
} > "$VERSION_FILE"

cat > "$MANIFEST_FILE" <<EOF
{
  "image": "$IMAGE",
  "image_repository": "$IMAGE_REPOSITORY",
  "version_type": "$IMAGE_VERSION_KIND",
  "version": "$IMAGE_VERSION",
  "platform": "$PLATFORM",
  "image_id": "$IMAGE_ID",
  "output_name": "$OUTPUT_NAME",
  "directory": "docker-images/$OUTPUT_NAME",
  "archive_file": "$ARCHIVE_FILE",
  "compression": "$COMPRESSION",
  "raw_tar_size_bytes": $RAW_SIZE,
  "stored_size_bytes": $COMPRESSED_SIZE,
  "split": $SPLIT,
  "split_size_mb": $SPLIT_SIZE_MB,
  "part_count": $PART_COUNT,
  "created_at": "$END_TIME",
  "checksum_file": "$(basename "$SHA_FILE")"
}
EOF

RAW_BASE_URL="https://raw.githubusercontent.com/${REPOSITORY}/${BRANCH}/docker-images/${OUTPUT_NAME}"
PAGE_BASE_URL="https://github.com/${REPOSITORY}/blob/${BRANCH}/docker-images/${OUTPUT_NAME}"
FOLDER_URL="https://github.com/${REPOSITORY}/tree/${BRANCH}/docker-images/${OUTPUT_NAME}"

case "$COMPRESSION" in
  zstd)
    COMPRESSION_TOOL="zstd"
    COMPRESSION_TOOL_URL="https://github.com/facebook/zstd/releases"
    UBUNTU_INSTALL="sudo apt update && sudo apt install -y docker.io zstd"
    MAC_INSTALL="brew install zstd"
    WINDOWS_INSTALL="choco install zstd"
    ;;
  gzip)
    COMPRESSION_TOOL="gzip"
    COMPRESSION_TOOL_URL="https://gnuwin32.sourceforge.net/packages/gzip.htm"
    UBUNTU_INSTALL="sudo apt update && sudo apt install -y docker.io gzip"
    MAC_INSTALL="# gzip is included with macOS by default"
    WINDOWS_INSTALL="choco install gzip"
    ;;
  xz)
    COMPRESSION_TOOL="xz"
    COMPRESSION_TOOL_URL="https://tukaani.org/xz/"
    UBUNTU_INSTALL="sudo apt update && sudo apt install -y docker.io xz-utils"
    MAC_INSTALL="brew install xz"
    WINDOWS_INSTALL="choco install xz"
    ;;
  none)
    COMPRESSION_TOOL="none"
    COMPRESSION_TOOL_URL="Not needed"
    UBUNTU_INSTALL="sudo apt update && sudo apt install -y docker.io"
    MAC_INSTALL="# Only Docker is required"
    WINDOWS_INSTALL="# Only Docker is required"
    ;;
esac

if [ "$SPLIT" = true ]; then
  DOWNLOAD_FILES="$(find "$OUTPUT_DIR" -maxdepth 1 -type f -name "${ARCHIVE_FILE}.part-*" -printf '%f\n' | sort)"
  DOWNLOAD_COMMANDS=""
  POWERSHELL_DOWNLOAD_COMMANDS=""
  for file in $DOWNLOAD_FILES; do
    DOWNLOAD_COMMANDS="${DOWNLOAD_COMMANDS}curl -L -o ${file} ${RAW_BASE_URL}/${file}
"
    POWERSHELL_DOWNLOAD_COMMANDS="${POWERSHELL_DOWNLOAD_COMMANDS}Invoke-WebRequest -Uri \"${RAW_BASE_URL}/${file}\" -OutFile \"${file}\"
"
  done
  POWERSHELL_HASH_COMMAND="Get-FileHash -Algorithm SHA256 ${ARCHIVE_FILE}.part-*"
  case "$COMPRESSION" in
    zstd)
      EXTRACT_COMMAND="cat ${ARCHIVE_FILE}.part-* > ${ARCHIVE_FILE}"
      LOAD_COMMAND="zstd -d -c ${ARCHIVE_FILE} | docker load"
      ;;
    gzip)
      EXTRACT_COMMAND="cat ${ARCHIVE_FILE}.part-* > ${ARCHIVE_FILE}"
      LOAD_COMMAND="gunzip -c ${ARCHIVE_FILE} | docker load"
      ;;
    xz)
      EXTRACT_COMMAND="cat ${ARCHIVE_FILE}.part-* > ${ARCHIVE_FILE}"
      LOAD_COMMAND="xz -d -c ${ARCHIVE_FILE} | docker load"
      ;;
    none)
      EXTRACT_COMMAND="cat ${ARCHIVE_FILE}.part-* > ${ARCHIVE_FILE}"
      LOAD_COMMAND="docker load -i ${ARCHIVE_FILE}"
      ;;
  esac
  POWERSHELL_COMBINE_COMMAND='$out = [System.IO.File]::Create("'"${ARCHIVE_FILE}"'")
Get-ChildItem -Filter "'"${ARCHIVE_FILE}.part-*"'" | Sort-Object Name | ForEach-Object {
    $in = [System.IO.File]::OpenRead($_.FullName)
    try { $in.CopyTo($out) } finally { $in.Close() }
}
$out.Close()'
  case "$COMPRESSION" in
    zstd) POWERSHELL_LOAD_COMMAND="zstd -d -c ${ARCHIVE_FILE} | docker load" ;;
    gzip) POWERSHELL_LOAD_COMMAND="gzip -d -c ${ARCHIVE_FILE} | docker load" ;;
    xz) POWERSHELL_LOAD_COMMAND="xz -d -c ${ARCHIVE_FILE} | docker load" ;;
    none) POWERSHELL_LOAD_COMMAND="docker load -i ${ARCHIVE_FILE}" ;;
  esac
else
  DOWNLOAD_FILE="$ARCHIVE_FILE"
  DOWNLOAD_FILES="$DOWNLOAD_FILE"
  DOWNLOAD_COMMANDS="curl -L -o ${DOWNLOAD_FILE} ${RAW_BASE_URL}/${DOWNLOAD_FILE}"
  POWERSHELL_DOWNLOAD_COMMANDS="Invoke-WebRequest -Uri \"${RAW_BASE_URL}/${DOWNLOAD_FILE}\" -OutFile \"${DOWNLOAD_FILE}\""
  POWERSHELL_HASH_COMMAND="Get-FileHash -Algorithm SHA256 ${DOWNLOAD_FILE}"
  EXTRACT_COMMAND="# Not needed. This backup is already a single archive file."
  case "$COMPRESSION" in
    zstd) LOAD_COMMAND="zstd -d -c ${DOWNLOAD_FILE} | docker load" ;;
    gzip) LOAD_COMMAND="gunzip -c ${DOWNLOAD_FILE} | docker load" ;;
    xz) LOAD_COMMAND="xz -d -c ${DOWNLOAD_FILE} | docker load" ;;
    none) LOAD_COMMAND="docker load -i ${DOWNLOAD_FILE}" ;;
  esac
  POWERSHELL_COMBINE_COMMAND="# Not needed. This backup is a single file."
  case "$COMPRESSION" in
    zstd) POWERSHELL_LOAD_COMMAND="zstd -d -c ${DOWNLOAD_FILE} | docker load" ;;
    gzip) POWERSHELL_LOAD_COMMAND="gzip -d -c ${DOWNLOAD_FILE} | docker load" ;;
    xz) POWERSHELL_LOAD_COMMAND="xz -d -c ${DOWNLOAD_FILE} | docker load" ;;
    none) POWERSHELL_LOAD_COMMAND="docker load -i ${DOWNLOAD_FILE}" ;;
  esac
fi

FILE_LINKS=""
for file in $DOWNLOAD_FILES "${OUTPUT_NAME}.manifest.json" "${OUTPUT_NAME}.sha256" "${OUTPUT_NAME}.info.txt" "VERSION.txt"; do
  FILE_LINKS="${FILE_LINKS}- [${file}](${PAGE_BASE_URL}/${file})
"
done

cat > "$README_FILE" <<EOF
# Docker image backup: \`$IMAGE\`

این فولدر برای این ساخته شده که بازیابی این Docker image تا جای ممکن ساده و بی‌دردسر باشد؛ مخصوصا وقتی سیستم مقصد به Docker Hub یا registry اصلی دسترسی راحتی ندارد.

## لینک فایل‌ها

$FILE_LINKS

Folder page: [$FOLDER_URL]($FOLDER_URL)

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
| Docker image | \`$IMAGE\` |
| Repository | \`$IMAGE_REPOSITORY\` |
| Version type | \`$IMAGE_VERSION_KIND\` |
| Version | \`$IMAGE_VERSION\` |
| Platform | \`$PLATFORM\` |
| Output folder | \`docker-images/$OUTPUT_NAME\` |
| Archive file | \`$ARCHIVE_FILE\` |
| Compression | \`$COMPRESSION\` |
| Split | \`$SPLIT\` |
| Part count | \`$PART_COUNT\` |

نسخه و جزئیات image داخل فایل [VERSION.txt](${PAGE_BASE_URL}/VERSION.txt) هم ذخیره شده است.

## ابزارهای مورد نیاز

همیشه Docker لازم است:

- Docker Desktop: https://www.docker.com/products/docker-desktop/
- Docker install docs: https://docs.docker.com/engine/install/

برای این backup ابزار زیر هم لازم است:

- Required compression tool: \`$COMPRESSION_TOOL\`
- Download page: $COMPRESSION_TOOL_URL

اگر با خطایی مثل \`zstd: command not found\` یا \`xz: command not found\` روبه‌رو شدید، یعنی ابزار مربوطه نصب نیست.

## Linux / macOS

### 1. نصب ابزارها

Ubuntu/Debian:

\`\`\`bash
$UBUNTU_INSTALL
\`\`\`

macOS:

\`\`\`bash
$MAC_INSTALL
\`\`\`

### 2. دانلود فایل‌ها

\`\`\`bash
mkdir -p ${OUTPUT_NAME}
cd ${OUTPUT_NAME}
$DOWNLOAD_COMMANDS
curl -L -o ${OUTPUT_NAME}.sha256 ${RAW_BASE_URL}/${OUTPUT_NAME}.sha256
\`\`\`

### 3. بررسی سالم بودن دانلود

\`\`\`bash
sha256sum -c ${OUTPUT_NAME}.sha256
\`\`\`

### 4. ساخت archive اصلی از قطعه‌ها

\`\`\`bash
$EXTRACT_COMMAND
\`\`\`

### 5. Load داخل Docker

\`\`\`bash
$LOAD_COMMAND
\`\`\`

### 6. بررسی نتیجه

\`\`\`bash
docker images
\`\`\`

## Windows PowerShell

### 1. نصب ابزارها

Docker Desktop:

https://www.docker.com/products/docker-desktop/

Compression tool:

$COMPRESSION_TOOL_URL

اگر Chocolatey دارید:

\`\`\`powershell
$WINDOWS_INSTALL
\`\`\`

### 2. دانلود فایل‌ها

\`\`\`powershell
New-Item -ItemType Directory -Force ${OUTPUT_NAME}
Set-Location ${OUTPUT_NAME}
$POWERSHELL_DOWNLOAD_COMMANDS
Invoke-WebRequest -Uri "${RAW_BASE_URL}/${OUTPUT_NAME}.sha256" -OutFile "${OUTPUT_NAME}.sha256"
\`\`\`

### 3. بررسی SHA256

PowerShell روی Windows به صورت پیش‌فرض فایل sha256sum لینوکسی را مستقیم نمی‌خواند. برای بررسی دستی، hash هر فایل را با مقدار داخل \`${OUTPUT_NAME}.sha256\` مقایسه کنید:

\`\`\`powershell
$POWERSHELL_HASH_COMMAND
\`\`\`

### 4. ساخت archive اصلی از قطعه‌ها

\`\`\`powershell
$POWERSHELL_COMBINE_COMMAND
\`\`\`

### 5. Load داخل Docker

\`\`\`powershell
$POWERSHELL_LOAD_COMMAND
\`\`\`

### 6. بررسی نتیجه

\`\`\`powershell
docker images
\`\`\`

## SHA256 یعنی چه؟

فایل \`${OUTPUT_NAME}.sha256\` برای این است که مطمئن شوید فایل‌هایی که دانلود کرده‌اید سالم، کامل و همان فایل‌هایی هستند که GitHub Action ساخته است.

این checksum نشان می‌دهد قطعه‌های archive بعد از ساخته شدن تغییری نکرده‌اند و دانلود شما ناقص یا خراب نیست.

نکته مهم: SHA256 اینجا برای فایل‌های backup داخل repo است، نه تایید امنیتی جداگانه درباره source image در Docker Hub.

## حمایت از پروژه

بزرگ‌ترین حمایت از ما معرفی و منتشر کردن این پروژه است. اگر این backup به شما کمک کرد، لطفا Docker Image Saver را به یک برنامه‌نویس، تیم یا شرکتی که با محدودیت Docker Hub یا registryها مشکل دارد معرفی کنید.

ما این ابزار را برای کم کردن فشار از روی تیم‌های فنی ساختیم. Star دادن، Fork کردن، ثبت Issue، ارسال Pull Request، معرفی پروژه و حمایت مالی، همه برای بهتر شدنش ارزشمندند.

### Donate

آدرس‌ها به ترتیب پیشنهادی قرار گرفته‌اند: اول شبکه‌های کم‌هزینه‌تر، و بین گزینه‌ها اولویت با USDT است.

#### USDT TRC20 (Tron) - پیشنهادی

\`\`\`text
TRNfUz3zXsJYDQMYG5zxDseX3MSFxx8bxr
\`\`\`

#### USDT SPL (Solana)

\`\`\`text
FcCT54fD8A3VQ7nqNNf4kZprgCjdEFrJ7BSQBDb7i13i
\`\`\`

#### USDT BEP20 (BNB Smart Chain)

\`\`\`text
0x1126A4023F4EC18CfeF036C71e94F5D7D6D0902B
\`\`\`

#### TON

\`\`\`text
UQCvY7I4ROxsYOldjfRR-QnjiwdMlCsMA6Jw2tu2lRLDx6BC
\`\`\`

#### TRX / Tron

\`\`\`text
TRNfUz3zXsJYDQMYG5zxDseX3MSFxx8bxr
\`\`\`

#### BNB

\`\`\`text
0x1126A4023F4EC18CfeF036C71e94F5D7D6D0902B
\`\`\`

#### BTC

\`\`\`text
bc1qnhjk9zqmpg3wytw47luy8qsu2jhwpz83ll265k
\`\`\`

ساخته شده با \`$PROJECT_NAME\` از تیم \`$PROJECT_TEAM\`.

ارادتمند، \`بهشت آئین\` از تیم \`$PROJECT_TEAM\`

وب‌سایت اپ ساز: $PROJECT_WEBSITE

Generated at: \`$END_TIME\`
EOF

echo "Done."
echo "Manifest: $MANIFEST_FILE"
echo "Info: $INFO_FILE"
echo "README: $README_FILE"
