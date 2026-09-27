## 1. Install the bindings

- [x] 1.1 Create `dot_config/zsh/conf.d/06-keybindings.zsh` that autoloads `up-line-or-beginning-search` and `down-line-or-beginning-search`, registers them with `zle -N`, and binds Up/Down to them in the `emacs` and `viins` keymaps; verify `zsh -n dot_config/zsh/conf.d/06-keybindings.zsh` passes
- [x] 1.2 Guard the fragment so that if the widget functions are not resolvable in `fpath` it prints a one-line warning instead of failing silently; verify by loading the fragment in a shell with the function directory removed from `fpath`
- [x] 1.3 Enable `setopt hist_find_no_dups` for the walk (in this fragment, beside the bindings); verify a repeated command is shown only once when walking a prefix

## 2. CI assertion

- [x] 2.1 Extend `ci/check-conveniences.sh` to assert, in the applied sandbox, that `bindkey -M emacs '^[[A'` and `bindkey -M viins '^[[A'` resolve to the prefix-search widget (and the Down equivalents); verify it passes after 1.1 and fails if the fragment is removed

## 3. Documentation

- [x] 3.1 Add a row to the README "Shell conveniences" table describing prefix history search (Up/Down walk commands beginning with the typed text); verify the text is accurate
- [x] 3.2 Record the change in `CHANGELOG.md` under a new MINOR version and verify `ci/check-version.sh` passes

## 4. Verification

- [x] 4.1 Drive the widgets in a pty and confirm: empty prompt + Up recalls the newest entry; `opens` + Up recalls the newest `opens…` entry and further presses walk older matches; Down returns to the typed line; no wrap past the oldest match; a multi-line buffer moves the cursor instead of searching; a non-matching prefix leaves the line unchanged
- [x] 4.2 Confirm the bindings work in both editing modes by starting a shell with `EDITOR=vim` (vi insert) and with `EDITOR=emacs`, and verifying the same behavior in each
- [x] 4.3 Run `ci/test-install.sh` and `ci/check-conveniences.sh` locally and confirm both pass
- [x] 4.4 Run `openspec validate "prefix-history-search" --strict` and confirm the change validates
