#!/usr/bin/env sh

SERVICES="waybar eww"

for service in $SERVICES; do
  sv up "$service" &
done

wait
