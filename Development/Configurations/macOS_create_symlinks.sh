#!/bin/bash
# ==================================================
# Auto create symlink for Dev / Prod flavors (macOS)
# Location: Development/Configurations
# ==================================================

set -e

# --------------------------------------------------
# Base dir (Configurations)
# --------------------------------------------------
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# --------------------------------------------------
# Source directories
# --------------------------------------------------
OEMS_DIR="$BASE_DIR/OEMs"
DEV_SOURCE="$OEMS_DIR/Dev/google-services.json"
PROD_SOURCE="$OEMS_DIR/Prod/google-services.json"

# --------------------------------------------------
# App src directory
# --------------------------------------------------
APP_SRC_DIR="$BASE_DIR/../../com.cisbox.core/app/src"

# --------------------------------------------------
# Validate sources
# --------------------------------------------------
if [ ! -f "$DEV_SOURCE" ]; then
  echo "[ERROR] Dev google-services.json not found"
  echo "$DEV_SOURCE"
  exit 1
fi

if [ ! -f "$PROD_SOURCE" ]; then
  echo "[ERROR] Prod google-services.json not found"
  echo "$PROD_SOURCE"
  exit 1
fi

echo "=================================================="
echo "Scanning app/src flavors"
echo "=================================================="
echo

# --------------------------------------------------
# Scan flavors
# --------------------------------------------------
for FLAVOR_DIR in "$APP_SRC_DIR"/*; do
  [ -d "$FLAVOR_DIR" ] || continue

  FLAVOR_NAME="$(basename "$FLAVOR_DIR")"
  TARGET="$FLAVOR_DIR/google-services.json"

  # ----- Dev suffix -----
  if [[ "$FLAVOR_NAME" == *Dev ]]; then
    SOURCE="$DEV_SOURCE"
    TYPE="Dev"

  # ----- Prod suffix -----
  elif [[ "$FLAVOR_NAME" == *Prod ]]; then
    SOURCE="$PROD_SOURCE"
    TYPE="Prod"

  else
    echo "[SKIP] $FLAVOR_NAME - not Dev/Prod flavor"
    continue
  fi

  if [ -e "$TARGET" ]; then
    echo "[INFO] $FLAVOR_NAME - deleting existing google-services.json"
    rm -f "$TARGET"
  fi

  echo "[LINK] $FLAVOR_NAME ($TYPE)"
  ln -s "$SOURCE" "$TARGET"
  echo "  [OK]"
  echo
done

echo "=================================================="
echo "[DONE] google-services.json processed"
echo "=================================================="
echo

# ==================================================
# Create symlink for shared BuildConfig.kt
# ==================================================

BUILD_CONFIG_SOURCE="$BASE_DIR/BuildConfig.kt"
BUILD_CONFIG_TARGET="$APP_SRC_DIR/main/java/com/cisbox/app/constant/BuildConfig.kt"

if [ ! -f "$BUILD_CONFIG_SOURCE" ]; then
  echo "[SKIP] BuildConfig.kt not found"
  exit 0
fi

TARGET_DIR="$(dirname "$BUILD_CONFIG_TARGET")"

if [ ! -d "$TARGET_DIR" ]; then
  echo "[CREATE] constant package directory"
  mkdir -p "$TARGET_DIR"
fi

if [ -e "$BUILD_CONFIG_TARGET" ]; then
  echo "[INFO] Deleting existing BuildConfig.kt"
  rm -f "$BUILD_CONFIG_TARGET"
fi

echo "[LINK] BuildConfig.kt"
ln -s "$BUILD_CONFIG_SOURCE" "$BUILD_CONFIG_TARGET"
echo "  [OK] BuildConfig.kt symlink created"

echo
echo "[ALL DONE]"
