# zsh-custom entrypoint — the stable interface.
#
# This file is sourced by the version-invariant managed block in ~/.zshrc.
# Do NOT put user configuration here: it lives in $ZSHRC_CUSTOM
# (default: ~/.config/zsh-custom) and survives every framework update.

# Guard against double-loading.
[[ -n ${ZSHRC_CUSTOM_LOADED:-} ]] && return 0
typeset -g ZSHRC_CUSTOM_LOADED=1

# Locate this file and the framework version.
typeset -g ZSHRC_CUSTOM_ROOT="${${(%):-%x}:A:h}"
typeset -g ZSHRC_CUSTOM_VERSION="$(<"$ZSHRC_CUSTOM_ROOT/VERSION" 2>/dev/null)"
: ${ZSHRC_CUSTOM_VERSION:=unknown}
typeset -gx ZSHRC_CUSTOM_ROOT ZSHRC_CUSTOM_VERSION

# User customization layer and cache locations.
: ${ZSHRC_CUSTOM:="${XDG_CONFIG_HOME:-$HOME/.config}/zsh-custom"}
: ${ZSHRC_CUSTOM_CACHE:="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-custom"}
typeset -gx ZSHRC_CUSTOM ZSHRC_CUSTOM_CACHE

typeset _zsc_f

# 1. Framework defaults (in lexical order).
for _zsc_f in "$ZSHRC_CUSTOM_ROOT"/conf.d/*.zsh(N); do
  source "$_zsc_f"
done

# 2. User configuration fragments (lexical order; overrides defaults).
if [[ -d "$ZSHRC_CUSTOM/conf.d" ]]; then
  for _zsc_f in "$ZSHRC_CUSTOM"/conf.d/*.zsh(N); do
    source "$_zsc_f"
  done
fi

# 3. User extra plugins (after the default plugin set).
[[ -r "$ZSHRC_CUSTOM/plugins.txt" ]] && zshrc_custom_load_plugins "$ZSHRC_CUSTOM/plugins.txt" >/dev/null

# 4. Syntax highlighting last, so it wraps the fully built command line.
[[ -r "$ZSHRC_CUSTOM_ROOT/zsh_plugins.last.txt" ]] && zshrc_custom_load_plugins "$ZSHRC_CUSTOM_ROOT/zsh_plugins.last.txt" >/dev/null

# 5. Escape hatch: always last, can override anything above.
[[ -r "$ZSHRC_CUSTOM/local.zsh" ]] && source "$ZSHRC_CUSTOM/local.zsh"

# Expose the framework CLI.
[[ -d "$ZSHRC_CUSTOM_ROOT/bin" ]] && path=("$ZSHRC_CUSTOM_ROOT/bin" $path)

unset _zsc_f
