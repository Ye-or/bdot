# android dev tools

## Установка android-studio (если нужен)

Необходим `xbps-src` для сборки пакета.

`$XBPS_SRC_DIR` - путь к директории `void-packages`.

Template должен лежать в `$XBPS_SRC_DIR/srcpkgs/android-studio`
Если template отсутствует в repos: `https://github.com/void-linux/void-packages.git`

```bash
mkdir $XBPS_SRC_DIR/srcpkgs/android-studio
```

Далее нужно создать или исправить файл template с учетом актуализации версии (если в template указана неактуальная версия то установка не выполнится).

```bash
vim $XBPS_SRC_DIR/srcpkgs/android-studio/template
```

```template
# Template file for 'android-studio'
pkgname=android-studio
version=2026.1.3.7
revision=1
_version_description="quail3"
archs="x86_64"
hostmakedepends="tar"
depends="libbsd"
short_desc="Official Android IDE"
maintainer="Bnyro <bnyro@tutanota.com>"
license="Apache-2.0"
homepage="https://developer.android.com/studio/"
changelog="https://developer.android.com/studio/releases/"
distfiles="https://edgedl.me.gvt1.com/android/studio/ide-zips/${version}/android-studio-${_version_description}-linux.tar.gz"
checksum=36832122557ab73ca68dfd9bd989ddac40103ac003ca10e04c949a1f61578a67
repository=nonfree
restricted=yes
python_version=3
nostrip=yes
noshlibprovides=yes
# These files are not run or loaded on the host thus skip scanning their runtime deps
skiprdeps="/opt/android-studio/plugins/android/resources/process-tracker-agent/native/x86_64/process-tracker
 /opt/android-studio/plugins/android/resources/process-tracker-agent/native/armeabi-v7a/process-tracker
 /opt/android-studio/plugins/android/resources/process-tracker-agent/native/arm64-v8a/process-tracker
 /opt/android-studio/plugins/android/resources/process-tracker-agent/native/x86/process-tracker
 /opt/android-studio/plugins/android/resources/screen-sharing-agent/x86_64/libscreen-sharing-agent.so
 /opt/android-studio/plugins/android/resources/screen-sharing-agent/armeabi-v7a/libscreen-sharing-agent.so
 /opt/android-studio/plugins/android/resources/screen-sharing-agent/arm64-v8a/libscreen-sharing-agent.so
 /opt/android-studio/plugins/android/resources/screen-sharing-agent/x86/libscreen-sharing-agent.so
 /opt/android-studio/plugins/android/resources/installer/x86_64/installer
 /opt/android-studio/plugins/android/resources/installer/armeabi-v7a/installer
 /opt/android-studio/plugins/android/resources/installer/arm64-v8a/installer
 /opt/android-studio/plugins/android/resources/installer/x86/installer
 /opt/android-studio/plugins/android/resources/transport/x86_64/transport
 /opt/android-studio/plugins/android/resources/transport/native/agent/x86_64/libjvmtiagent.so
 /opt/android-studio/plugins/android/resources/transport/native/agent/armeabi-v7a/libjvmtiagent.so
 /opt/android-studio/plugins/android/resources/transport/native/agent/arm64-v8a/libjvmtiagent.so
 /opt/android-studio/plugins/android/resources/transport/native/agent/x86/libjvmtiagent.so
 /opt/android-studio/plugins/android/resources/transport/armeabi-v7a/transport
 /opt/android-studio/plugins/android/resources/transport/arm64-v8a/transport
 /opt/android-studio/plugins/android/resources/transport/x86/transport
 /opt/android-studio/plugins/android/resources/perfetto/x86_64/libperfetto.so
 /opt/android-studio/plugins/android/resources/perfetto/x86_64/traced_probes
 /opt/android-studio/plugins/android/resources/perfetto/x86_64/traced
 /opt/android-studio/plugins/android/resources/perfetto/x86_64/perfetto
 /opt/android-studio/plugins/android/resources/perfetto/armeabi-v7a/libperfetto.so
 /opt/android-studio/plugins/android/resources/perfetto/armeabi-v7a/traced_probes
 /opt/android-studio/plugins/android/resources/perfetto/armeabi-v7a/traced
 /opt/android-studio/plugins/android/resources/perfetto/armeabi-v7a/perfetto
 /opt/android-studio/plugins/android/resources/perfetto/arm64-v8a/libperfetto.so
 /opt/android-studio/plugins/android/resources/perfetto/arm64-v8a/traced_probes
 /opt/android-studio/plugins/android/resources/perfetto/arm64-v8a/traced
 /opt/android-studio/plugins/android/resources/perfetto/arm64-v8a/perfetto
 /opt/android-studio/plugins/android/resources/perfetto/x86/libperfetto.so
 /opt/android-studio/plugins/android/resources/perfetto/x86/traced_probes
 /opt/android-studio/plugins/android/resources/perfetto/x86/traced
 /opt/android-studio/plugins/android/resources/perfetto/x86/perfetto
 /opt/android-studio/plugins/android-ndk/resources/lldb/lib/python3.11/lib-dynload/_curses.cpython-311-x86_64-linux-gnu.so
 /opt/android-studio/plugins/android-ndk/resources/lldb/lib/python3.11/lib-dynload/_curses_panel.cpython-311-x86_64-linux-gnu.so"

do_install() {
 vmkdir opt/${pkgname}
 vcopy bin opt/${pkgname}/
 vcopy lib opt/${pkgname}/
 vcopy jbr opt/${pkgname}/
 vcopy plugins opt/${pkgname}/
 vcopy build.txt opt/${pkgname}/ # read as IDE version information
 vcopy product-info.json opt/${pkgname}/
 vmkdir usr/bin
 ln -s /opt/android-studio/bin/studio ${DESTDIR}/usr/bin/android-studio

 vinstall ${FILESDIR}/android-studio.desktop 644 usr/share/applications
 chmod -R ugo+rX ${DESTDIR}/opt
}
```

Далее как указано в [xbps-src.md](/info/xbps-src.md)

## [Android SDK и NDK (Без Android Studio)](https://developer.android.com/tools). Если стоит android-studio то можно поставить через нее если нет то в соответствии с указаниями на сайте. Есть разные вариации установки: UI, CL, tar
