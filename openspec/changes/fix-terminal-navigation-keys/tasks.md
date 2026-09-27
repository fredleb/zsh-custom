## 1. Extend the keybindings fragment

- [x] 1.1 Add a small guarded helper to `dot_config/zsh/conf.d/06-keybindings.zsh` that binds a sequence only when it is non-empty, and load `zsh/terminfo` with `zmodload -i`; verify `zsh -n` passes and the fragment loads with no error when `TERM` is unset
- [x] 1.2 Bind Delete, Insert, Home, End, PageUp, and PageDown (terminfo capability plus literal alternates) in the `emacs`, `viins`, and `vicmd` keymaps, using the widgets in `design.md`; verify each sequence resolves to its widget via `bindkey` in a `TERM=xterm` shell
- [x] 1.3 Confirm the existing arrow bindings are unchanged and no other binding is clobbered; verify by diffing `bindkey -M emacs`, `-M viins`, and `-M vicmd` before and after loading the fragment

## 2. Behavioural verification

- [x] 2.1 Drive a pty in both the emacs and vi insert modes and confirm the buffer result for each key: Delete deletes the character under the cursor, Home/End move to the line bounds, Insert toggles overwrite, PageUp/PageDown move within a multi-line buffer, and vi insert mode is not left
- [x] 2.2 Confirm portability: with `TERM=tmux-256color` (Home/End `^[[1~`/`^[[4~`) the keys still work, and with `TERM=dumb` the shell starts with no error and the literal fallbacks still bind

## 3. CI assertion

- [x] 3.1 Extend `ci/check-conveniences.sh` (setting `TERM=xterm`) to assert each navigation key resolves to its widget in the `emacs`, `viins`, and `vicmd` keymaps; verify it passes after 1.2 and fails when the bindings are removed

## 4. Documentation and release

- [x] 4.1 Add a README row describing working navigation keys (Delete/Home/End/Insert/PageUp/PageDown) in any editing mode; verify the text is accurate
- [x] 4.2 Add a `CHANGELOG.md` entry under a new MINOR version and verify `ci/check-version.sh` passes

## 5. Verification

- [x] 5.1 Run `ci/test-install.sh` and `ci/check-conveniences.sh` locally and confirm both pass
- [x] 5.2 Run `openspec validate "fix-terminal-navigation-keys" --strict` and confirm the change validates
