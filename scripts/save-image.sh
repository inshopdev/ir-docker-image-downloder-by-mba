#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-}"
OUTPUT_NAME="${2:-}"
COMPRESSION="${COMPRESSION:-zstd}"
ZSTD_LEVEL="${ZSTD_LEVEL:-10}"
SPLIT_SIZE_MB="${SPLIT_SIZE_MB:-95}"
OUTPUT_ROOT="${OUTPUT_DIR:-docker-images}"
REPOSITORY="${GITHUB_REPOSITORY:-OWNER/REPO}"
BRANCH="${GITHUB_REF_NAME:-master}"

if [ -z "$IMAGE" ]; then
  echo "Usage: $0 <docker-image> [output-name]"
  echo "Example: $0 nginx:alpine nginx-alpine"
  exit 1
fi

command -v docker >/dev/null 2>&1 || { echo "docker is required"; exit 1; }

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

OUTPUT_DIR="${OUTPUT_ROOT}/${OUTPUT_NAME}"
mkdir -p "$OUTPUT_DIR" .tmp

RAW_TAR=".tmp/${OUTPUT_NAME}.tar"
BASE="${OUTPUT_DIR}/${OUTPUT_NAME}"
START_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "Pulling image: $IMAGE"
if ! docker pull "$IMAGE"; then
  echo ""
  echo "Docker could not pull: $IMAGE"
  echo ""
  echo "Use the real Docker image name in the workflow input."
  echo "Examples:"
  echo "  nginx:alpine"
  echo "  bugsink/bugsink"
  echo "  ghcr.io/owner/image:tag"
  echo ""
  echo "Do not put the generated folder name as the image name."
  echo "For example, use 'bugsink/bugsink' as the image and let this tool create the folder 'bugsink-bugsink'."
  exit 1
fi

echo "Saving Docker image to tar"
docker save "$IMAGE" -o "$RAW_TAR"

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
SPLIT_SIZE_BYTES=$((SPLIT_SIZE_MB * 1024 * 1024))
SPLIT=false
PART_COUNT=0

if [ "$COMPRESSED_SIZE" -gt "$SPLIT_SIZE_BYTES" ]; then
  echo "Splitting into ${SPLIT_SIZE_MB}MB parts"
  split -b "${SPLIT_SIZE_MB}M" -d -a 3 "$OUT_FILE" "${BASE}.part-"
  rm -f "$OUT_FILE"
  SPLIT=true
  PART_COUNT="$(find "$OUTPUT_DIR" -maxdepth 1 -type f -name "${OUTPUT_NAME}.part-*" | wc -l | tr -d ' ')"
fi

SHA_FILE="${BASE}.sha256"
if [ "$SPLIT" = true ]; then
  (cd "$OUTPUT_DIR" && sha256sum "${OUTPUT_NAME}".part-* > "${OUTPUT_NAME}.sha256")
else
  (cd "$OUTPUT_DIR" && sha256sum "$(basename "$OUT_FILE")" > "${OUTPUT_NAME}.sha256")
fi

END_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
INFO_FILE="${BASE}.info.txt"
MANIFEST_FILE="${BASE}.manifest.json"
README_FILE="${OUTPUT_DIR}/README.md"

cat > "$INFO_FILE" <<EOF
Image: $IMAGE
Output name: $OUTPUT_NAME
Compression: $COMPRESSION
Raw tar size: $RAW_SIZE bytes
Stored size: $COMPRESSED_SIZE bytes
Split: $SPLIT
Part count: $PART_COUNT
Started: $START_TIME
Finished: $END_TIME
EOF

cat > "$MANIFEST_FILE" <<EOF
{
  "image": "$IMAGE",
  "output_name": "$OUTPUT_NAME",
  "directory": "docker-images/$OUTPUT_NAME",
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

if [ "$SPLIT" = true ]; then
  DOWNLOAD_FILES="$(find "$OUTPUT_DIR" -maxdepth 1 -type f -name "${OUTPUT_NAME}.part-*" -printf '%f\n' | sort)"
  DOWNLOAD_COMMANDS=""
  POWERSHELL_DOWNLOAD_COMMANDS=""
  for file in $DOWNLOAD_FILES; do
    DOWNLOAD_COMMANDS="${DOWNLOAD_COMMANDS}curl -L -o ${file} ${RAW_BASE_URL}/${file}
"
    POWERSHELL_DOWNLOAD_COMMANDS="${POWERSHELL_DOWNLOAD_COMMANDS}Invoke-WebRequest -Uri \"${RAW_BASE_URL}/${file}\" -OutFile \"${file}\"
"
  done
  case "$COMPRESSION" in
    zstd) LOAD_COMMAND="cat ${OUTPUT_NAME}.part-* | zstd -d -c | docker load" ;;
    gzip) LOAD_COMMAND="cat ${OUTPUT_NAME}.part-* | gunzip -c | docker load" ;;
    xz) LOAD_COMMAND="cat ${OUTPUT_NAME}.part-* | xz -d -c | docker load" ;;
    none) LOAD_COMMAND="cat ${OUTPUT_NAME}.part-* | docker load" ;;
  esac
  POWERSHELL_COMBINE_COMMAND='$out = [System.IO.File]::Create("image.compressed")
Get-ChildItem -Filter "*.part-*" | Sort-Object Name | ForEach-Object {
    $in = [System.IO.File]::OpenRead($_.FullName)
    try { $in.CopyTo($out) } finally { $in.Close() }
}
$out.Close()'
  case "$COMPRESSION" in
    zstd) POWERSHELL_LOAD_COMMAND="zstd -d -c image.compressed | docker load" ;;
    gzip) POWERSHELL_LOAD_COMMAND="gzip -d -c image.compressed | docker load" ;;
    xz) POWERSHELL_LOAD_COMMAND="xz -d -c image.compressed | docker load" ;;
    none) POWERSHELL_LOAD_COMMAND="docker load -i image.compressed" ;;
  esac
else
  DOWNLOAD_FILE="$(basename "$OUT_FILE")"
  DOWNLOAD_FILES="$DOWNLOAD_FILE"
  DOWNLOAD_COMMANDS="curl -L -o ${DOWNLOAD_FILE} ${RAW_BASE_URL}/${DOWNLOAD_FILE}"
  POWERSHELL_DOWNLOAD_COMMANDS="Invoke-WebRequest -Uri \"${RAW_BASE_URL}/${DOWNLOAD_FILE}\" -OutFile \"${DOWNLOAD_FILE}\""
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
for file in $DOWNLOAD_FILES "${OUTPUT_NAME}.manifest.json" "${OUTPUT_NAME}.sha256" "${OUTPUT_NAME}.info.txt"; do
  FILE_LINKS="${FILE_LINKS}- [${file}](${PAGE_BASE_URL}/${file})
"
done

cat > "$README_FILE" <<EOF
# Docker image backup: \`$IMAGE\`

This folder contains everything needed to download and load this Docker image without using Docker Hub.

## Files

$FILE_LINKS

## Linux / macOS

### 1. Download the files

\`\`\`bash
mkdir -p ${OUTPUT_NAME}
cd ${OUTPUT_NAME}
$DOWNLOAD_COMMANDS
curl -L -o ${OUTPUT_NAME}.sha256 ${RAW_BASE_URL}/${OUTPUT_NAME}.sha256
\`\`\`

### 2. Check the download

\`\`\`bash
sha256sum -c ${OUTPUT_NAME}.sha256
\`\`\`

### 3. Load into Docker

\`\`\`bash
$LOAD_COMMAND
\`\`\`

## Windows PowerShell

### 1. Download the files

\`\`\`powershell
New-Item -ItemType Directory -Force ${OUTPUT_NAME}
Set-Location ${OUTPUT_NAME}
$POWERSHELL_DOWNLOAD_COMMANDS
Invoke-WebRequest -Uri "${RAW_BASE_URL}/${OUTPUT_NAME}.sha256" -OutFile "${OUTPUT_NAME}.sha256"
\`\`\`

### 2. Extract or combine files

\`\`\`powershell
$POWERSHELL_COMBINE_COMMAND
\`\`\`

### 3. Load into Docker

\`\`\`powershell
$POWERSHELL_LOAD_COMMAND
\`\`\`

## Requirements

- Docker must be installed and running.
- For zstd backups, install \`zstd\`.
- For xz backups, install \`xz\`.

Generated at: \`$END_TIME\`
EOF

echo "Done."
echo "Manifest: $MANIFEST_FILE"
echo "Info: $INFO_FILE"
echo "README: $README_FILE"
