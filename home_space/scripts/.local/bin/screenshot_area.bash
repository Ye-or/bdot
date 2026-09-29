#!/bin/bash
set -euo pipefail
grim -g "$(slurp)" - | wl-copy
