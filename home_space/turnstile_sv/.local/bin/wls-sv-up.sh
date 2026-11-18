#!/usr/bin/env sh

SERVICES="waybar eww clipcatd awwwd swayidle"

for service in $SERVICES; do
  sv up "$service" &
done

wait
