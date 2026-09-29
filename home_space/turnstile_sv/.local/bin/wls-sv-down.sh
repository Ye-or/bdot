#!/usr/bin/env sh

SERVICES="waybar eww"

for service in $SERVICES; do
  sv down "$service" &
done

wait
