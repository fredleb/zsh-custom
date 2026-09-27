# Starship prompt (system-installed). Fail-soft if it is not available.

if (( $+commands[starship] )); then
  typeset _zsc_starship_config="$ZSHRC_CUSTOM_ROOT/starship.toml"
  # User prompt override wins over the framework default.
  [[ -r "$ZSHRC_CUSTOM/theme.toml" ]] && _zsc_starship_config="$ZSHRC_CUSTOM/theme.toml"
  export STARSHIP_CONFIG="$_zsc_starship_config"
  eval "$(starship init zsh)"
  unset _zsc_starship_config
else
  print -u2 "zsh-custom: warning: starship not found; keeping the default zsh prompt."
  print -u2 "            Install 'starship' system-wide (see README) and restart your shell."
fi
