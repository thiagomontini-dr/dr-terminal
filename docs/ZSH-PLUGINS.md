# Oh My Zsh Plugins

Quick guide to the plugins enabled in `~/.zshrc`, with a short explanation of each one and how to use it.

> Created: 2026-07-10
> Last updated: 2026-07-11

> Note: `zoxide` (final section) is not an Oh My Zsh plugin, but a separate tool loaded manually in `~/.zshrc`. It is documented here for convenience.

Load order matters: `zsh-syntax-highlighting` and `zsh-history-substring-search` must always be the last two (in this order), as stated in the official documentation.

## Index

| Plugin | Category | Summary |
|--------|----------|---------|
| git | Git | Aliases and functions for Git |
| git-auto-fetch | Git | Automatic `git fetch` in the background |
| fzf | Search | Integration with the fuzzy finder |
| macos | System | macOS-specific utilities |
| sudo | System | Prefixes the command with `sudo` (ESC ESC) |
| extract | Files | Extracts any compressed file with one command |
| copypath | Clipboard | Copies the current path |
| copyfile | Clipboard | Copies the contents of a file |
| copybuffer | Clipboard | Copies the current command line (Ctrl+O) |
| dirhistory | Navigation | Navigates directory history with Alt+arrows |
| web-search | Search | Searches the web straight from the terminal |
| colored-man-pages | Display | Colorizes `man` pages |
| command-not-found | System | Suggests a package when the command does not exist |
| zsh-completions | Completions | Extra completions for many commands |
| zsh-autosuggestions | Productivity | History-based suggestions as you type |
| zsh-syntax-highlighting | Display | Colorizes valid and invalid commands as you type |
| zsh-history-substring-search | History | Searches history by typed substring |
| zoxide (external) | Navigation | Smart `cd` by a fragment of the folder name |

---

## Git and versioning

### git

Provides dozens of aliases for Git. The most used:

- `gst` → `git status`
- `gco` → `git checkout`
- `gcb` → `git checkout -b` (create and switch branch)
- `gaa` → `git add --all`
- `gcmsg "msg"` → `git commit -m "msg"`
- `gp` → `git push`
- `gl` → `git pull`
- `gd` → `git diff`
- `glog` → `git log --oneline --decorate --graph`

List all: `alias | grep "='git"`.

### git-auto-fetch

Runs `git fetch` automatically in the background while you work, keeping the repository in sync with the remote.

- Pause temporarily: `git-auto-fetch` (toggles on/off in the current directory).
- The default interval is 60 seconds.

---

## Search

### fzf

Integrates the fuzzy finder into the shell.

- `Ctrl+R` → interactive search in the command history.
- `Ctrl+T` → inserts the selected file/folder into the command line.
- `Alt+C` → enters (`cd`) an interactively chosen directory.
- `command **<TAB>` → fuzzy completion (e.g. `cd **<TAB>`, `vim **<TAB>`).

### web-search

Searches the web from the terminal, opening the browser.

- `google search term`
- `ddg term` (DuckDuckGo)
- `github repository`
- `stackoverflow error`

---

## System

### macos

macOS utilities. Useful commands:

- `ofd` → opens Finder in the current directory.
- `pfd` → prints the path of the focused Finder window.
- `cdf` → enters the directory currently open in Finder.
- `showfiles` / `hidefiles` → shows/hides hidden files in Finder.
- `rmdsstore` → removes `.DS_Store` files recursively.

### sudo

Press `ESC` twice to add (or remove) `sudo` at the start of the current command line. Useful when a command fails for lack of permission.

### command-not-found

When you type a command that does not exist, it suggests the package (Homebrew) that provides it.

---

## Files and clipboard

### extract

Extracts any compressed file with a single command, without remembering the flags of each format.

- `extract file.tar.gz`
- `extract file.zip`
- Supports `.tar`, `.gz`, `.bz2`, `.zip`, `.rar`, `.7z`, among others.

### copypath

- `copypath` → copies the absolute path of the current directory to the clipboard.
- `copypath file.txt` → copies the path of the given file.

### copyfile

- `copyfile file.txt` → copies the contents of the file to the clipboard.

### copybuffer

- `Ctrl+O` → copies the command line currently being typed to the clipboard.

---

## Navigation

### dirhistory

Navigates the history of visited directories with the keyboard:

- `Alt+←` / `Alt+→` → go back/forward in the directory history.
- `Alt+↑` → go up one level (parent directory).
- `Alt+↓` → go down into a recently visited subdirectory.

---

## Display

### colored-man-pages

Applies colors to manual pages, making them easier to read. Just use `man command` as usual.

### zsh-syntax-highlighting

Colorizes commands as you type:

- Green → valid/found command.
- Red → nonexistent command or syntax error.

Helps you spot errors before pressing Enter. Requires no configuration.

---

## Productivity and history

### zsh-completions

Adds completions (suggestions with `TAB`) for hundreds of commands and tools that Zsh does not cover by default. Transparent to use: just press `TAB`.

### zsh-autosuggestions

As you type, it suggests in light gray the most likely command based on your history.

- `→` (right arrow) or `End` → accept the full suggestion.
- `Ctrl+→` → accept only the next word of the suggestion.

### zsh-history-substring-search

Searches history by a typed substring. Type part of a command and navigate through the matches:

- `Ctrl+P` → previous result (configured in `.zshrc`).
- `Ctrl+N` → next result (configured in `.zshrc`).
- In vi mode: `k` / `j` in command mode.

It is configured to return only unique results (`HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1`).

---

## External tool

### zoxide

Not an Oh My Zsh plugin, but a separate tool loaded at the end of `~/.zshrc`:

```bash
eval "$(zoxide init zsh --cmd cd)"
```

Because of `--cmd cd`, in this setup zoxide replaces `cd` itself (it does not use the `z` command). It memorizes visited folders and lets you return to them by typing just a fragment of the name.

How it works: enter a folder once by its full path; afterward it becomes available as a shortcut from anywhere.

```bash
cd ~/projects/dr-terminal   # first visit, normal path
cd terminal                 # afterward, jump straight to ~/projects/dr-terminal
```

Commands and tricks:

- `cd fragment` → go to the best folder matching the fragment.
- `cd foo bar` → match `foo` and `bar` in the path at the same time.
- `cdi fragment` → interactive mode: opens a list (fzf) to choose.
- `cd -` → go back to the previous folder.
- `cd` (alone) → go to home, like the traditional `cd`.

The ranking uses "frecency" (frequency of use + how recent the access was): the more you use a folder, the easier it is to reach.

Limitation: zoxide only finds folders you have already visited at least once. New folders must be accessed by their full path before they become shortcuts.

#### Seed the history at once (new machine)

To avoid visiting each folder manually, the repository includes the script `scripts/seed-zoxide.sh`, which registers the given parent folders and all their first-level subfolders in the zoxide database.

```bash
# default folders: Projects, Desktop, Documents, Downloads
./scripts/seed-zoxide.sh

# or providing your own parent folders
./scripts/seed-zoxide.sh Projects Work ~/dev /opt/apps
```

Paths can be relative to `HOME` (`Projects`), use `~` (`~/dev`), or be absolute (`/opt/apps`). Folders that do not exist on the machine are ignored, so the same list works across different machines. The script uses `zoxide add` (zoxide's internal method) and requires zoxide to be already installed.

After running it, all subfolders start with the same weight (frecency); as you use them, the most frequent ones rise in the ranking.

---

## Apply changes

After editing `~/.zshrc`, reload with:

```bash
reload
# or
source ~/.zshrc
```
