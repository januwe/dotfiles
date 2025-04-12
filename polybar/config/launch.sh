#!/usr/bin/env bash

killall -q polybar

# launch sys bar
echo "---" | tee -a /tmp/polybar.log
polybar sys 2>&1 | tee -a /tmp/polybar.log & disown
echo "Bar launched..."
