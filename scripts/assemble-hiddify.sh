#!/usr/bin/env bash
set -euo pipefail

OUT="$(realpath "${1:-./Hiddify-RPMx86_64.AppImage}")"

podman run --rm \
    -v "$(dirname "$OUT"):/out:Z" \
    registry.opensuse.org/opensuse/tumbleweed:latest \
    bash -euc '
        zypper -n install wget tar squashfs file

        wget "https://github.com/hiddify/hiddify-app/releases/download/v4.0.4/Hiddify-Linux-x64-AppImage.tar.gz" \
            -O Hiddify.tar.gz
        tar -xf Hiddify.tar.gz --wildcards "*.AppImage" --strip-components=1

        chmod +x Hiddify.AppImage
        APPIMAGE_EXTRACT_AND_RUN=1 ./Hiddify.AppImage --appimage-extract

        sed -i "/LD_LIBRARY_PATH=usr\/lib/a export LD_LIBRARY_PATH=\"/usr/lib64:\${APPDIR}/usr/lib:\${LD_LIBRARY_PATH}\"\nexport LIBGL_ALWAYS_SOFTWARE=1" squashfs-root/AppRun

        wget "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage" \
            -O appimagetool
        chmod +x appimagetool

        wget "https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64" \
            -O runtime-x86_64

        APPIMAGE_EXTRACT_AND_RUN=1 ARCH=x86_64 ./appimagetool \
            --runtime-file runtime-x86_64 \
            squashfs-root /tmp/Hiddify-patched.AppImage

        mv /tmp/Hiddify-patched.AppImage /out/'"$(basename "$OUT")"'
    '

echo "Done: $OUT"
