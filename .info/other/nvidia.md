# nvidia

[void linux](https://docs.voidlinux.org/config/graphical-session/graphics-drivers/nvidia.html#nvidia-nvidia-provided-driver)
[freedesktop.org](https://nouveau.freedesktop.org/CodeNames.html):NV137 (GP107):GeForce GTX (1050, 1050 Ti)

В Void Linux: начиная с серии драйверов **595.xx**, основной пакет `nvidia` и `nvidia-dkms` в репозиториях Void Linux был переключен на использование **открытых (open) модулей ядра** по умолчанию.

Эти открытые модули **требуют наличия GSP** (GPU System Processor), которого физически нет в видеокарте GTX 1050 (архитектура Pascal). Именно поэтому ядро честно пишет: `not supported by open nvidia.ko because it does not include the required GPU System Processor (GSP)`.

## Решение: установить проприетарную (закрытую) версию драйвера

Для видеокарт архитектуры Maxwell, Pascal и Volta документация Void Linux официально рекомендует использовать пакет **`nvidia580`**, который по-прежнему содержит классические **закрытые (proprietary) модули ядра**, идеально работающие с GTX 1050 без требований к GSP.

Выполнить команды по порядку:

**1. Полностью удаляем проблемные пакеты 595-й серии:**

```bash
sudo xbps-remove -R nvidia nvidia-dkms nvidia-open nvidia-open-dkms
```

**2. Устанавливаем проприетарную 580-ю серию драйверов:**

```bash
sudo xbps-install -S nvidia580 nvidia580-dkms
```

*(Система автоматически запустит сборку DKMS-модуля для вашего ядра `6.18.38_1`.

**3. Обновляем initramfs, чтобы новый модуль корректно загрузился на раннем этапе:**

```bash
sudo dracut --force
```

**4. Перезагружаем ноутбук:**

```bash
sudo reboot
```

---

### Финальная проверка после перезагрузки

Когда система загрузится, выполните:

```bash
lspci -k -d ::03xx
```

Теперь в строке `01:00.0` вы **гарантированно** увидите:
`Kernel driver in use: nvidia`

Как только это произойдет, подключите HDMI-кабель. Niri мгновенно подхватит внешний монитор, а при выдергивании и повторном подключении шнура система больше не будет "терять" его, так как закрытый драйвер `nvidia` корректно обрабатывает hotplug-события на ноутбуках с Optimus.
