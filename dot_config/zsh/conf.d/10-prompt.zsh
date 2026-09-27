# Starship prompt. Config lives at ~/.config/starship.toml (chezmoi-managed).
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
else
  print -u2 "zsh: warning: starship not found; keeping the default prompt."
  print -u2 "     macOS: brew install starship | Debian/Ubuntu: sudo apt-get install starship"
fi
