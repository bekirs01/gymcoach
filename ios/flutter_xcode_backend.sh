#!/bin/sh
# Xcode Run Script ortamında PATH çok kısıtlı olur; cmake (dartcv4 / native assets) bulunamaz.
# Bu yüzden Homebrew + yaygın yolları ekleyip Flutter'ın xcode_backend.sh dosyasını çalıştırırız.
set -e

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:${PATH}"

if ! command -v cmake >/dev/null 2>&1; then
  # Android Studio CMake (sürüm klasörü değişebilir)
  for d in "${HOME}/Library/Android/sdk/cmake"/*/bin; do
    if [ -x "${d}/cmake" ]; then
      export PATH="${d}:${PATH}"
      break
    fi
  done
fi

exec /bin/sh "${FLUTTER_ROOT}/packages/flutter_tools/bin/xcode_backend.sh" "$@"
