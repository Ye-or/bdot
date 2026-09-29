```markdown
---
tags:
  - dev/android
  - troubleshooting
  - linux/void
  - adb
  - slop
created: 2026-08-14
---

# 🔌 Решение проблемы пустого списка `adb devices` на Void Linux

Если команда `adb devices` возвращает пустой список, на **Void Linux** проблема практически всегда кроется в одной из трёх причин: отсутствие `udev`-правил для Android-устройств, неверный режим подключения USB или дефектный кабель.

> [!abstract] План действий
> Пройдите по следующим шагам для диагностики и решения проблемы.

---

## 1. Проверка физического подключения и режима USB

* **Кабель:** Убедитесь, что шнур не является «только зарядным». Он **обязан** поддерживать передачу данных.
* **Режим подключения (MTP/PTP):** Когда вы подключаете телефон к ПК, на шторке уведомлений Android появляется выбор режима. Попробуйте переключить его с *«Зарядка только»* на *«Передача файлов (MTP)»* или *«Передача фото (PTP)»*. На некоторых прошивках ADB инициализируется только в этих режимах.
* **Проверка видимости на уровне ядра:** Введите в терминале:
  ```bash
  lsusb
  ```

  Посмотрите, появляется ли в списке ваше устройство (например, `Google Inc.`, `Xiaomi`, `Samsung`).
  > [!warning] Важно
  > Если вашего телефона нет в выводе `lsusb`, проблема исключительно физическая (неисправный кабель, плохой порт USB).

---

## 2. Настройка `udev`-правил (Специфика Void Linux)

В отличие от дистрибутивов вроде Ubuntu, Void по умолчанию не имеет базы идентификаторов Android-устройств. Система видит USB-устройство, но у обычного пользователя нет прав на чтение/запись в этот порт, поэтому `adb` (запущенный от вашего пользователя) его игнорирует.

### Шаг 2.1: Установка правил

Установите пакет с готовыми правилами для Android (он содержит Vendor ID почти всех брендов):

```bash
sudo xbps-install -S android-udev-rules
```

### Шаг 2.2: Добавление пользователя в группу

Добавьте вашего пользователя в группу `adbusers`, чтобы получить доступ к устройствам:

```bash
sudo usermod -aG adbusers $USER
```

*(Примечание: `sudo umask 022` может потребоваться в некоторых специфичных окружениях перед изменением пользователей, но обычно `usermod` достаточно).*

### Шаг 2.3: Применение правил

Перезагрузите правила `udev`, чтобы они вступили в силу:

```bash
sudo udevadm control --reload-rules && sudo udevadm trigger
```

### Шаг 2.4: Перелогин
>
> [!important] Обязательный шаг
> Обязательно **перезайдите в систему** (разлогиньтесь и зайдите снова в сессию Niri), чтобы применились права новой группы `$USER`. Либо выполните в текущем терминале `su - $USER` для временного обновления групп.

---

## 3. Перезапуск демона ADB

После выполнения шагов выше отключите кабель от телефона и сбросьте сервер ADB:

```bash
adb kill-server
adb start-server
```

Снова подключите телефон по USB и проверьте список:

```bash
adb devices
```

---

## 4. Подтверждение авторизации на экране телефона

Если всё сделано верно, телефон появится в списке. При первом подключении статус будет `unauthorized`.

1. В этот момент **включите экран телефона** — там появится всплывающее окно с вопросом: *«Разрешить отладку по USB с этого компьютера?»*.
2. Поставьте галочку *«Всегда разрешать с этого компьютера»* и нажмите **ОК**.

После этого статус сменится на `device`, и проект Tauri сможет деплоить на него сборки.

---

## ❓ Если после настройки `udev` список устройств всё ещё пуст

Пришлите для дальнейшей диагностики:

1. Вывод команды `lsusb` при подключенном телефоне.
2. Информацию о том, появляется ли в шторке телефона уведомление о том, что отладка по USB включена.

---

### 📚 Источники и ссылки

<details>
<summary>Показать список источников</summary>

* [[1] void-packages/issues/21850](https://github.com/void-linux/void-packages/issues/21850)
* [[2] Reddit: Need help with android mtp and adb devices](https://www.reddit.com/r/voidlinux/comments/bv599g/need_help_with_android_mtp_and_adbdevices/)
* [[3] YouTube: ADB devices empty fix](https://www.youtube.com/watch?v=We45D_TjKdc)
* [[4] Reddit: Still wont show up in adb](https://www.reddit.com/r/essential/comments/80xisf/still_wont_show_up_in_adb/)
* [[5] StackOverflow: List of devices attached is empty](https://stackoverflow.com/questions/46128913/list-of-devices-attached-is-empty-on-ubuntu-16-04-using-adb-devices)
* [[6] Gist: lsusb Android Vendors](https://gist.github.com/715264/b2f4436a917363b02b5b69964cf43c168dffc420)
* [[7] StackOverflow: Android adb device offline](https://stackoverflow.com/questions/14993855/android-adb-device-offline-cant-issue-commands)
* [[8] YouTube: ADB unauthorized fix](https://www.youtube.com/watch?v=VLjM8tWKN1U)
* [[9] GitHub: scrcpy/issues/6450](https://github.com/Genymobile/scrcpy/issues/6450)

</details>
```
