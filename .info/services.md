# service

## Проверка всех сервисов

[turnstile](https://github.com/chimera-linux/turnstile.git)

```bash
sv status <path_service>/*
```

- системные сервисы: `sudo sv status /var/service/*`
- пользовательские сервисы (при использовании `turnstile`): `sv status ~/.config/service/*`

хранилище сервисов в `/etc/sv/`

Templates: [madand/runit-services](https://github.com/madand/runit-services.git)
