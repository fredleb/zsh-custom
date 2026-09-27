# Load the per-user secrets file, warning if its permissions are too open.

typeset _zsc_secrets="$ZSHRC_CUSTOM/secrets.zsh"
if [[ -r "$_zsc_secrets" ]]; then
  typeset _zsc_mode
  if [[ "$OSTYPE" == darwin* ]]; then
    _zsc_mode="$(stat -f '%Lp' "$_zsc_secrets" 2>/dev/null)"
  else
    _zsc_mode="$(stat -c '%a' "$_zsc_secrets" 2>/dev/null)"
  fi
  # Warn when group/other permission bits are set (not 0600/0700).
  if [[ -n "$_zsc_mode" ]] && (( 8#$_zsc_mode & 077 )); then
    print -u2 "zsh-custom: warning: $_zsc_secrets is mode $_zsc_mode; restrict it with: chmod 600 $_zsc_secrets"
  fi
  source "$_zsc_secrets"
fi
unset _zsc_secrets _zsc_mode
