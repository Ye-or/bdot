#!/usr/bin/env sh

SERVICES="waybar eww clipcatd awwwd"

for service in $SERVICES; do
  sv down "$service" &
done

wait
