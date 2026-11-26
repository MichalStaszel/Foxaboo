#!/usr/bin/env bash
# Fails if the APK asks for anything beyond what the app needs. Foxaboo
# promises parents that nothing leaves the phone, so INTERNET must never be
# in a build we hand out.
set -euo pipefail
apk="$1"
aapt2=$(ls -d "${ANDROID_HOME:-$ANDROID_SDK_ROOT}"/build-tools/*/aapt2 | sort -V | tail -1)
perms=$("$aapt2" dump permissions "$apk" | sed -n "s/.*uses-permission: name='\([^']*\)'.*/\1/p" | sort -u)
echo "Permissions in $apk:"
echo "$perms" | sed 's/^/  /'
allowed='^(android\.permission\.CAMERA|com\.android\.vending\.BILLING|android\.permission\.WAKE_LOCK|.*\.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION)$'
bad=$(echo "$perms" | grep -Ev "$allowed" || true)
if [ -n "$bad" ]; then
  echo "Not allowed:" >&2
  echo "$bad" | sed 's/^/  /' >&2
  exit 1
fi
