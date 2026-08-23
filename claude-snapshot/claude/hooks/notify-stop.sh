#!/bin/bash
# Ghostty OSC 9 desktop notification on Claude stop.
# Inside tmux, wrap in DCS passthrough so the sequence reaches the outer terminal.
if [ -n "$TMUX" ]; then
  printf '\ePtmux;\e\e]9;Claude: 응답 완료\a\e\\' > /dev/tty 2>/dev/null
else
  printf '\e]9;Claude: 응답 완료\a' > /dev/tty 2>/dev/null
fi
true
