## 1. Add the modifier bindings

- [x] 1.1 Add Shift+Delete (`^[[3;2~`), Ctrl+Delete (`^[[3;5~`), and Alt+Delete (`^[[3;3~`) to `dot_config/zsh/conf.d/06-keybindings.zsh` using the existing `_zsc_bind_nav` helper (delete-char / vi-delete-char, kill-word, backward-kill-word); verify `zsh -n` passes and each sequence resolves via `bindkey` in the emacs, viins, and vicmd keymaps
- [x] 1.2 Confirm the plain navigation bindings are unchanged; verify by diffing `bindkey -M emacs` before and after loading the fragment

## 2. Behavioural verification

- [x] 2.1 Drive a pty in the emacs and vi insert modes and confirm Shift+Delete deletes the character under the cursor, Ctrl+Delete deletes the following word, and Alt+Delete deletes the preceding word, without leaving vi insert mode
- [x] 2.2 Reproduce under a nested tmux with the byobu profile (`xterm-keys on`) and confirm the same results for `^[[3;2~`, `^[[3;5~`, and `^[[3;3~`

## 3. CI assertion

- [x] 3.1 Extend `ci/check-conveniences.sh` to assert the three modifier sequences resolve to their widgets; verify it passes and fails when the bindings are removed

## 4. Documentation and release

- [x] 4.1 Note the Delete-key modifier combinations in the README shell-conveniences row and add a `CHANGELOG.md` entry under a new MINOR version; verify `ci/check-version.sh` passes

## 5. Verification

- [x] 5.1 Run `ci/test-install.sh` and `ci/check-conveniences.sh` locally and confirm both pass
- [x] 5.2 Run `openspec validate "bind-modified-delete-keys" --strict` and confirm the change validates
