#!/bin/bash

exec chromium --proxy-server="http=127.0.0.1:8881;https=127.0.0.1:8881" "$@"
