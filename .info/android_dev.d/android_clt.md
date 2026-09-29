
[Android CLI](https://developer.android.com/tools/agents)

```sh
 curl -fsSL https://dl.google.com/android/cli/latest/linux_x86_64/install.sh | bash 
```

```sh
sudo vim /etc/udev/rules.d/51-android.rules
```

```txt
SUBSYSTEM=="usb", ATTR{idVendor}=="*", ATTR{idProduct}=="*", MODE="0666", GROUP="plugdev"
```

```sh
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### Подпись

```sh
keytool -genkey -v -keystore my-release-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000 -storepass "MyPassword123" -keypass "MyPassword123" -dname "CN=MyName, OU=Dev, O=MyCompany, L=City, S=State, C=RU"
```

```sh
~/Android/Sdk/build-tools/35.0.0/apksigner sign --ks my-release-key.keystore --ks-pass pass:"ВашПароль" --out app-final.apk /home/egomode/src/impact/src-tauri/gen/android/app/build/outputs/apk/universal/release/app-universal-release-unsigned.apk
```

### Удаление/Установка

```sh
adb uninstall dev.impact.app
adb install app-final.apk
```
