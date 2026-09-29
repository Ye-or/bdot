#!/bin/bash
# Массовый автоперезапуск демонов через pidof
# Настройте массивы SERVICES и START_CMDS одинаковой длины.

declare -r -a SERVICES=(pipewire pipewire-pulse wireplumber) # имена для pidof
declare -a START_CMDS=()
for i in "${!SERVICES[@]}"; do
  START_CMDS[i]="${SERVICES[i]} &" # или любое преобразование
done

declare -i MAX_RETRIES=0 # 0 = бесконечно
declare -i SLEEP_RETRY=1 # пауза после попытки старта конкретного сервиса

# массив счётчиков попыток
declare -a retries
for i in "${!SERVICES[@]}"; do retries[$i]=0; done

for i in "${!SERVICES[@]}"; do
  while true; do
    svc="${SERVICES[$i]}"
    if pgrep -x "$svc" >/dev/null; then
      # запущен — сбрасываем счётчик
      retries[$i]=0
      break
    else
      ((retries[$i]++))
      echo "${SERVICES[$i]}"
      eval "${START_CMDS[$i]}"
      sleep "$SLEEP_RETRY"
    fi

    if [[ $MAX_RETRIES -ne 0 && ${retries[$i]} -ge $MAX_RETRIES ]]; then
      echo "${retries[$i]}"
      retries[$i]=$MAX_RETRIES
      break
    fi

  done
done
