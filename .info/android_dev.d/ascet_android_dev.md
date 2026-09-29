```markdown
---
tags:
  - dev/android
  - dev/rust
  - dev/tauri
  - linux/void
  - linux/wayland
  - wm/niri
  - slop
created: 2026-08-14
---

# 🤖 Разработка Android-приложений (Rust + Tauri v2) на Void Linux без Android Studio

Для разработки Android-приложений на **Void Linux (Wayland + Niri)** с использованием связки **Rust + Tauri v2 (mobile)** можно полностью обойтись без тяжелой Android Studio. Вам понадобится легковесный набор консольных инструментов (CLI), компиляторы и легковесный редактор кода.

> [!abstract] Введение
> Ниже представлен полный список необходимых инструментов и пошаговый процесс настройки окружения и отладки.

---

## 🧰 1. Необходимые инструменты (Инструментарий)

Так как вы работаете на Void Linux, большинство пакетов устанавливаются через `xbps-install`, а специфичные для Android компоненты — через официальный менеджер пакетов SDK (`sdkmanager`).

### 1.1 Системные зависимости и Rust
* **Rustup:** Рекомендуется использовать `rustup` (а не системный `rust`), чтобы легко добавлять Android-таргеты.
* **Зависимости Tauri:** Для сборки под Android Tauri требует наличия компилятора C и библиотек.

```bash
sudo xbps-install -S rustup base-devel pkg-config openssl-devel
```

* **Android-таргеты для Rust:** Добавьте необходимые архитектуры (обычно достаточно `aarch64` для реальных устройств и `x86_64` для эмулятора).

```bash
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
```

### 1.2 Android SDK и NDK (Без Android Studio)

Вместо установки Android Studio, вам нужны только **Command line tools**.

1. **Установите Java Development Kit** (Tauri v2 отлично работает с OpenJDK 17):

   ```bash
   sudo xbps-install -S openjdk17-bootstrap # или openjdk17
   ```

2. **Скачайте Command line tools** с официального сайта [Android Developers](https://developer.android.com/studio#command-line-tools-only) (раздел *"Command line tools only"*).
3. **Распакуйте их** в удобную директорию (например, `~/Android/Sdk`).
   > [!warning] Внимание
   > Структура папок внутри должна быть строго `cmdline-tools/latest/bin/...`, чтобы утилиты работали корректно.
4. **Установите необходимые компоненты** (SDK, NDK, Platform-tools):

   ```bash
   ~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager --update
   ~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager "platforms;android-34" "build-tools;34.0.0" "ndk;26.1.10909125" "platform-tools"
   ```

   *(Версии SDK и NDK лучше уточнить в актуальной документации Tauri v2, обычно требуются NDK r25/r26).*

### 1.3 Переменные окружения
>
> [!important] Обязательно для Niri / Zsh / Bash
> Пропишите следующие переменные в ваш конфигурационный файл (`~/.bashrc` или `~/.zshrc`):

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export NDK_HOME=$ANDROID_HOME/ndk/26.1.10909125 # Укажите вашу установленную версию NDK
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
```

---

## 💻 2. Запуск и отладка (Wayland / Niri)

В экосистеме Tauri запуск мобильного режима происходит через команду `cargo tauri android dev`. Однако вам нужно устройство, куда это приложение будет транслироваться.

### Вариант А: Физическое Android-устройство (Рекомендуется)

*Самый простой и легкий вариант для Void Linux.*

1. Включите **Режим разработчика** и **Отладку по USB** на вашем смартфоне.
2. Подключите смартфон по USB к компьютеру.
3. Проверьте, что система видит устройство через ADB:

   ```bash
   adb devices
   ```

   *(Если устройство в статусе `unauthorized`, подтвердите запрос на экране смартфона).*
4. Запустите проект в режиме разработки:

   ```bash
   cargo tauri android dev
   ```

   *Tauri сам скомпилирует проект, соберет APK, установит его на телефон и запустит hot-reload (изменения во фронтенде будут мгновенно отображаться на телефоне).*

### Вариант Б: Эмулятор на ПК (Нюансы с Wayland/Niri)

Если вы хотите запускать эмулятор на ПК без Android Studio, вам придется использовать CLI-утилиту `emulator`.

1. **Скачайте системный образ и создайте виртуальное устройство (AVD):**

   ```bash
   sdkmanager "system-images;android-34;google_apis;x86_64"
   avdmanager create avd -n test_android -k "system-images;android-34;google_apis;x86_64"
   ```

2. **Запуск в Wayland/Niri:**
   Эмулятор Android использует QEMU и Qt. В Wayland (особенно в тайлинговых композиторах вроде Niri) он может капризничать, пытаться запуститься через XWayland или открываться в неудобном размере.

   *Для принудительного запуска под Wayland используйте переменную:*

   ```bash
   QT_QPA_PLATFORM=wayland emulator -avd test_android
   ```

   *Если эмулятор ведет себя некорректно в Niri (склеивается, не меняет размер), попробуйте запустить его в режиме XWayland:*

   ```bash
   QT_QPA_PLATFORM=xcb emulator -avd test_android
   ```

3. После того как эмулятор загрузился, `adb devices` покажет его в списке, и вы сможете вызвать `cargo tauri android dev`.

---

## 🛠️ 3. Чем заменить Android Studio?

Так как Tauri — это преимущественно Rust (бэкенд) и Web-технологии (фронтенд: HTML/CSS/JS/TS), Android Studio вам не сослужит хорошую службу, она создана под Java/Kotlin.

### Идеальный сетап для Niri

* **Редактор:**
  * [Neovim](https://neovim.io/) или [Helix](https://helix-editor.com/) (отлично вписываются в CLI/Tiling философию).
  * [VS Code](https://code.visualstudio.com/) / [VSCodium](https://vscodium.com/) (запущенный в native Wayland режиме: `--ozone-platform-hint=auto`).
* **Плагины:**
  * `rust-analyzer` — для идеальной автодописочки и навигации по Rust-коду.
  * Любой `LSP` для вашего веб-фреймворка (Svelte, Vue, React или vanilla TS).
* **Инструмент логирования:**
  Вместо встроенного Logcat в Android Studio, используйте в соседнем терминале:

  ```bash
  adb logcat *:S Tauri:V Rust:V
  ```

  *Это отфильтрует логи вашего Tauri приложения прямо в консоли.*
* **Отладка Web-части:**
  Для консоли браузера Tauri при запуске `dev` предоставляет ссылку на инспектирование (можно открыть в Chromium-браузере по адресу `chrome://inspect`).

---

## 💡 Резюме

Связка **Void Linux + Niri + Tauri** — это прекрасный, очень легковесный стек. Вам не нужна Android Studio.
Все, что вам требуется: `rustup` + `openjdk17` + `android-commandlinetools` (для компилятора Gradle и ADB), а разработка ведется в любом текстовом редакторе.

> [!tip] Совет
> Физический телефон для отладки сбережет вам кучу оперативной памяти по сравнению с эмулятором.

*Если у вас возникнут трудности с первоначальной настройкой шаблона Tauri v2 под Android, обратите внимание на этап (инициализация `tauri android init` или сборка) и изучите логи сборщика Gradle.*

```
