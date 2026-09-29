# nvidia-power

## Install

- nvidia580
- nvidia580-dkms

```sh
sudo xbps-install \
nvidia580 \
nvidia580-dkms 
```

## Configurate

```tree
/etc/modprobe.d
├── disable-nouveau.conf
└── nvidia-power.conf
```

```sh
DOT_PATH="${HOME}/.dotfiles"

sudo install -o root -g root -m 0644 \
  "${DOT_PATH}/acer_nvidia_specifi/etc/modprobe.d/disable-nouveau.conf" \
  /etc/modprobe.d/disable-nouveau.conf

sudo install -o root -g root -m 0644 \
  "${DOT_PATH}/acer_nvidia_specifi/etc/modprobe.d/nvidia-power.conf" \
  /etc/modprobe.d/nvidia-power.conf
```

## Execute

```sh
sudo dracut -f
```
