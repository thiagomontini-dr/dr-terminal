# Troubleshooting Guide

**Common issues and solutions for DR Custom Terminal.**

This guide covers installation problems, configuration issues, and common errors you might encounter.

---

## Table of Contents

- [Installation Issues](#installation-issues)
  - [Installer Fails to Start](#installer-fails-to-start)
  - [Permission Denied Errors](#permission-denied-errors)
  - [Network/Download Failures](#networkdownload-failures)
  - [Xcode Command Line Tools Issues](#xcode-command-line-tools-issues)
  - [Homebrew Installation Problems](#homebrew-installation-problems)
- [Font Issues](#font-issues)
  - [Icons Not Displaying](#icons-not-displaying)
  - [Square Boxes Instead of Icons](#square-boxes-instead-of-icons)
  - [Font Installation Failed](#font-installation-failed)
- [Oh My ZSH Issues](#oh-my-zsh-issues)
  - [Oh My ZSH Not Loading](#oh-my-zsh-not-loading)
  - [Theme Not Applying](#theme-not-applying)
  - [Plugins Not Working](#plugins-not-working)
- [Powerlevel10k Issues](#powerlevel10k-issues)
  - [Configuration Wizard Not Starting](#configuration-wizard-not-starting)
  - [Instant Prompt Not Working](#instant-prompt-not-working)
  - [Slow Prompt Performance](#slow-prompt-performance)
- [ZSH Plugin Conflicts](#zsh-plugin-conflicts)
  - [Syntax Highlighting Not Working](#syntax-highlighting-not-working)
  - [Autosuggestions Not Appearing](#autosuggestions-not-appearing)
  - [History Search Issues](#history-search-issues)
- [Utility Tool Problems](#utility-tool-problems)
  - [fzf Keybindings Not Working](#fzf-keybindings-not-working)
  - [bat Colors Not Showing](#bat-colors-not-showing)
  - [zoxide Not Learning Directories](#zoxide-not-learning-directories)
- [Path and Environment Issues](#path-and-environment-issues)
  - [Command Not Found After Installation](#command-not-found-after-installation)
  - [Homebrew Commands Not Available](#homebrew-commands-not-available)
  - [Duplicate PATH Entries](#duplicate-path-entries)
- [Shell Configuration Issues](#shell-configuration-issues)
  - [Changes Not Taking Effect](#changes-not-taking-effect)
  - [Slow Shell Startup](#slow-shell-startup)
  - [Configuration Conflicts](#configuration-conflicts)
- [Reset and Uninstall](#reset-and-uninstall)
  - [Resetting to Default Configuration](#resetting-to-default-configuration)
  - [Removing Individual Modules](#removing-individual-modules)
  - [Complete Uninstallation](#complete-uninstallation)
- [macOS-Specific Issues](#macos-specific-issues)
- [Frequently Asked Questions](#frequently-asked-questions)

---

## Installation Issues

### Installer Fails to Start

**Symptoms:**
- `./install.sh` shows "Permission denied"
- Script doesn't execute

**Solutions:**

1. **Make script executable:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

2. **Check file format (Unix vs Windows line endings):**
   ```bash
   # Convert if needed
   dos2unix install.sh
   # Or on macOS
   sed -i '' 's/\r$//' install.sh
   ```

3. **Run with bash explicitly:**
   ```bash
   bash install.sh
   ```

---

### Permission Denied Errors

**Symptoms:**
- "Permission denied" during installation
- Cannot write to system directories

**Solutions:**

1. **For user directory installations (normal):**
   ```bash
   # No sudo needed for ~/.zshrc, ~/.oh-my-zsh, etc.
   # If prompted for password, it's for Xcode CLI tools only
   ```

2. **Fix ownership of home directory:**
   ```bash
   # If permissions are broken
   sudo chown -R $(whoami):staff $HOME
   ```

3. **Don't run installer with sudo:**
   ```bash
   # Wrong
   sudo ./install.sh

   # Correct
   ./install.sh
   ```

---

### Network/Download Failures

**Symptoms:**
- "Failed to download"
- "Could not resolve host"
- Timeout errors

**Solutions:**

1. **Check internet connection:**
   ```bash
   ping -c 3 google.com
   ```

2. **Check DNS:**
   ```bash
   # Try Google DNS
   sudo networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4
   ```

3. **Retry installation:**
   ```bash
   # Downloads may be interrupted
   ./install.sh
   ```

4. **Check firewall/VPN:**
   - Disable VPN temporarily
   - Check corporate firewall settings
   - Ensure GitHub is accessible

5. **Use different network:**
   - Try mobile hotspot
   - Switch Wi-Fi networks

---

### Xcode Command Line Tools Issues

**Symptoms:**
- "xcode-select: error: command line tools are already installed"
- Installation hangs at Xcode CLI
- Git not working after installation

**Solutions:**

1. **Check existing installation:**
   ```bash
   xcode-select -p
   # Should output: /Library/Developer/CommandLineTools
   ```

2. **Remove and reinstall:**
   ```bash
   sudo rm -rf /Library/Developer/CommandLineTools
   xcode-select --install
   ```

3. **Accept license agreement:**
   ```bash
   sudo xcodebuild -license accept
   ```

4. **Reset xcode-select:**
   ```bash
   sudo xcode-select --reset
   ```

5. **Manual installation:**
   - Open Terminal
   - Run: `xcode-select --install`
   - Click "Install" in popup window
   - Wait for download to complete

---

### Homebrew Installation Problems

**Symptoms:**
- Homebrew installation fails
- "Failed to download Homebrew"
- Homebrew commands not found

**Solutions:**

1. **Clean previous installation:**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
   ```

2. **Reinstall Homebrew manually:**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. **Fix permissions:**
   ```bash
   # Intel Mac
   sudo chown -R $(whoami) /usr/local/Homebrew

   # Apple Silicon Mac
   sudo chown -R $(whoami) /opt/homebrew
   ```

4. **Add Homebrew to PATH manually:**
   ```bash
   # For Apple Silicon
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc

   # For Intel
   echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc

   # Reload
   source ~/.zshrc
   ```

5. **Check installation:**
   ```bash
   brew doctor
   ```

---

## Font Issues

### Icons Not Displaying

**Symptoms:**
- Squares (□) instead of icons
- Missing symbols in Powerlevel10k prompt
- No icons in `eza` output

**Solutions:**

1. **Install Nerd Font:**
   ```bash
   ./modules/fonts/nerd-fonts.sh quick meslo
   ```

2. **Set terminal font:**

   **iTerm2:**
   - ⌘, → Profiles → Text → Font
   - Select "MesloLGS NF"
   - Restart iTerm2

   **Terminal.app:**
   - ⌘, → Profiles → Font
   - Select "MesloLGS NF"
   - Restart Terminal

3. **Verify font installation:**
   ```bash
   # macOS
   fc-list | grep -i "meslo"

   # Or check Font Book
   open -a "Font Book"
   ```

4. **Test icons in terminal:**
   ```bash
   echo ""  # Should show folder icon
   echo ""  # Should show Git branch icon
   ```

5. **Try different Nerd Font:**
   ```bash
   ./modules/fonts/nerd-fonts.sh quick jetbrains
   # Then set "JetBrains Mono Nerd Font" in terminal
   ```

---

### Square Boxes Instead of Icons

**Symptoms:**
- □ □ □ displayed instead of proper icons
- Some icons work, others don't

**Solutions:**

1. **Ensure you're using Nerd Font variant:**
   ```bash
   # Must select the "NF" (Nerd Font) variant
   # Correct:   "MesloLGS NF"
   # Incorrect: "MesloLGS"
   ```

2. **Check font size:**
   - Some icons don't render well at very small sizes
   - Try 12-14pt font size

3. **Update terminal application:**
   - Older terminal apps may not support all Unicode characters
   - Update iTerm2 to latest version

4. **Check character encoding:**
   ```bash
   # Ensure UTF-8 encoding
   echo $LANG
   # Should output: en_US.UTF-8

   # If not, add to ~/.zshrc
   export LANG=en_US.UTF-8
   export LC_ALL=en_US.UTF-8
   ```

---

### Font Installation Failed

**Symptoms:**
- "Failed to install font"
- Font not appearing in terminal font list

**Solutions:**

1. **Manual installation:**
   ```bash
   # Download font manually
   brew install --cask font-meslo-lg-nerd-font

   # Or from GitHub
   cd ~/Downloads
   curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip
   unzip Meslo.zip
   open *.ttf
   # Click "Install Font"
   ```

2. **Clear font cache:**
   ```bash
   # macOS
   sudo atsutil databases -remove
   atsutil server -shutdown
   atsutil server -ping
   ```

3. **Restart applications:**
   - Quit and reopen terminal completely
   - Restart Mac if fonts still don't appear

4. **Check installation location:**
   ```bash
   ls ~/Library/Fonts | grep -i meslo
   ls /Library/Fonts | grep -i meslo
   ```

---

## Oh My ZSH Issues

### Oh My ZSH Not Loading

**Symptoms:**
- Default ZSH prompt instead of Oh My ZSH theme
- No Oh My ZSH features available

**Solutions:**

1. **Check if Oh My ZSH is installed:**
   ```bash
   ls -la ~/.oh-my-zsh
   # Should show directory
   ```

2. **Verify .zshrc sources Oh My ZSH:**
   ```bash
   grep "oh-my-zsh.sh" ~/.zshrc
   # Should show: source $ZSH/oh-my-zsh.sh
   ```

3. **Check ZSH variable:**
   ```bash
   echo $ZSH
   # Should output: /Users/yourusername/.oh-my-zsh
   ```

4. **Reload configuration:**
   ```bash
   source ~/.zshrc
   # Or
   exec zsh
   ```

5. **Reinstall Oh My ZSH:**
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

---

### Theme Not Applying

**Symptoms:**
- Selected theme doesn't appear
- Default "robbyrussell" theme shows instead

**Solutions:**

1. **Check theme setting in .zshrc:**
   ```bash
   grep "^ZSH_THEME" ~/.zshrc
   ```

2. **For Powerlevel10k:**
   ```bash
   # Should be:
   ZSH_THEME="powerlevel10k/powerlevel10k"

   # Check installation
   ls ~/.oh-my-zsh/custom/themes/powerlevel10k
   ```

3. **Reload configuration:**
   ```bash
   source ~/.zshrc
   ```

4. **Run Powerlevel10k configuration:**
   ```bash
   p10k configure
   ```

5. **Check for theme conflicts:**
   ```bash
   # Ensure only one ZSH_THEME line
   grep ZSH_THEME ~/.zshrc
   ```

---

### Plugins Not Working

**Symptoms:**
- Installed plugins don't function
- Plugin commands not recognized

**Solutions:**

1. **Check plugins array in .zshrc:**
   ```bash
   grep "^plugins=" ~/.zshrc
   ```

   Should look like:
   ```bash
   plugins=(
     git
     zsh-autosuggestions
     zsh-syntax-highlighting
   )
   ```

2. **Verify plugin installation:**
   ```bash
   # For custom plugins
   ls ~/.oh-my-zsh/custom/plugins/

   # Should show: zsh-autosuggestions, zsh-syntax-highlighting, etc.
   ```

3. **Reload configuration:**
   ```bash
   source ~/.zshrc
   ```

4. **Reinstall plugin:**
   ```bash
   ./modules/plugins/zsh-autosuggestions.sh install
   ```

5. **Check plugin order:**
   - `zsh-syntax-highlighting` must be last in plugins array
   ```bash
   plugins=(
     git
     zsh-autosuggestions
     zsh-syntax-highlighting  # MUST be last
   )
   ```

---

## Powerlevel10k Issues

### Configuration Wizard Not Starting

**Symptoms:**
- `p10k configure` does nothing
- Configuration wizard doesn't appear on first launch

**Solutions:**

1. **Run manually:**
   ```bash
   p10k configure
   ```

2. **Remove existing configuration:**
   ```bash
   rm ~/.p10k.zsh
   source ~/.zshrc
   # Should trigger wizard
   ```

3. **Check installation:**
   ```bash
   echo $POWERLEVEL9K_VERSION
   # Should show version number
   ```

4. **Reinstall Powerlevel10k:**
   ```bash
   rm -rf ~/.oh-my-zsh/custom/themes/powerlevel10k
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
   ```

---

### Instant Prompt Not Working

**Symptoms:**
- Slow terminal startup
- Warnings about instant prompt

**Solutions:**

1. **Enable instant prompt in .zshrc:**
   ```bash
   # Should be BEFORE sourcing oh-my-zsh.sh
   if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
     source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
   fi
   ```

2. **Move slow commands after Oh My ZSH:**
   ```bash
   # In ~/.zshrc, move these AFTER sourcing oh-my-zsh.sh:
   # - nvm initialization
   # - rbenv initialization
   # - pyenv initialization
   ```

3. **Reconfigure Powerlevel10k:**
   ```bash
   p10k configure
   # Select "Yes" for instant prompt
   ```

---

### Slow Prompt Performance

**Symptoms:**
- Delay when typing
- Prompt takes seconds to appear
- High CPU usage

**Solutions:**

1. **Disable unused segments in ~/.p10k.zsh:**
   ```bash
   # Remove segments you don't need from:
   typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(...)
   typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(...)
   ```

2. **Optimize Git status:**
   ```bash
   # Add to ~/.p10k.zsh
   typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=4096
   ```

3. **Disable Git in large repositories:**
   ```bash
   # In large repos
   git config bash.showDirtyState false
   ```

4. **Use instant prompt:**
   ```bash
   p10k configure
   # Enable instant prompt option
   ```

5. **Check for shell startup issues:**
   ```bash
   # Profile zsh startup
   zsh -xv 2>&1 | tee /tmp/zsh-startup.log
   ```

---

## ZSH Plugin Conflicts

### Syntax Highlighting Not Working

**Symptoms:**
- No color highlighting for commands
- All commands appear in same color

**Solutions:**

1. **Ensure plugin is last in array:**
   ```bash
   # In ~/.zshrc
   plugins=(
     git
     zsh-autosuggestions
     zsh-syntax-highlighting  # MUST be last
   )
   ```

2. **Check installation:**
   ```bash
   ls ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
   ```

3. **Reload configuration:**
   ```bash
   source ~/.zshrc
   ```

4. **Reinstall plugin:**
   ```bash
   rm -rf ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
   ```

5. **Check for conflicts:**
   ```bash
   # Temporarily disable other plugins
   plugins=(zsh-syntax-highlighting)
   source ~/.zshrc
   ```

---

### Autosuggestions Not Appearing

**Symptoms:**
- No gray suggestions while typing
- Suggestions used to work but stopped

**Solutions:**

1. **Check installation:**
   ```bash
   ls ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
   ```

2. **Verify plugin is enabled:**
   ```bash
   grep "zsh-autosuggestions" ~/.zshrc
   # Should be in plugins array
   ```

3. **Check suggestion color:**
   ```bash
   # Add to ~/.zshrc
   ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
   source ~/.zshrc
   ```

4. **Clear history if corrupted:**
   ```bash
   rm ~/.zsh_history
   # Start new terminal
   ```

5. **Reinstall plugin:**
   ```bash
   ./modules/plugins/zsh-autosuggestions.sh install
   ```

6. **Test with simple command:**
   ```bash
   # Type a command you've used before
   ls
   # Should see suggestion in gray
   ```

---

### History Search Issues

**Symptoms:**
- Up arrow doesn't search history by substring
- History search not working

**Solutions:**

1. **Check plugin installation:**
   ```bash
   ls ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search
   ```

2. **Verify keybindings:**
   ```bash
   # Add to ~/.zshrc after plugins
   bindkey '^[[A' history-substring-search-up
   bindkey '^[[B' history-substring-search-down
   ```

3. **Reload configuration:**
   ```bash
   source ~/.zshrc
   ```

4. **Check history file:**
   ```bash
   echo $HISTFILE
   # Should show: /Users/yourusername/.zsh_history

   # Check if readable
   cat $HISTFILE | head
   ```

---

## Utility Tool Problems

### fzf Keybindings Not Working

**Symptoms:**
- CTRL-R doesn't open fzf history search
- CTRL-T doesn't insert files
- ALT-C doesn't change directory

**Solutions:**

1. **Check fzf installation:**
   ```bash
   which fzf
   # Should show: /opt/homebrew/bin/fzf or /usr/local/bin/fzf
   ```

2. **Source fzf keybindings in .zshrc:**
   ```bash
   # Add to ~/.zshrc
   [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

   # Or for Homebrew installation
   source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
   source /opt/homebrew/opt/fzf/shell/completion.zsh
   ```

3. **Reload configuration:**
   ```bash
   source ~/.zshrc
   ```

4. **Run fzf install script:**
   ```bash
   $(brew --prefix)/opt/fzf/install
   # Answer yes to keybindings
   ```

5. **Check for conflicting keybindings:**
   ```bash
   # Temporarily disable other plugins that might bind CTRL-R
   ```

---

### bat Colors Not Showing

**Symptoms:**
- bat output is plain text
- No syntax highlighting

**Solutions:**

1. **Check bat installation:**
   ```bash
   bat --version
   ```

2. **Test with simple file:**
   ```bash
   bat ~/.zshrc
   # Should show colors
   ```

3. **Check terminal color support:**
   ```bash
   echo $COLORTERM
   # Should show: truecolor or 24bit

   # Check if terminal supports 256 colors
   tput colors
   # Should show: 256
   ```

4. **Set bat theme:**
   ```bash
   # List themes
   bat --list-themes

   # Set theme
   export BAT_THEME="Nord"
   echo 'export BAT_THEME="Nord"' >> ~/.zshrc
   ```

5. **Force color output:**
   ```bash
   bat --color=always file.txt
   ```

6. **Reset bat config:**
   ```bash
   rm ~/.config/bat/config
   bat cache --build
   ```

---

### zoxide Not Learning Directories

**Symptoms:**
- `z` command doesn't jump to directories
- zoxide database seems empty

**Solutions:**

1. **Check zoxide installation:**
   ```bash
   zoxide --version
   ```

2. **Ensure zoxide is initialized in .zshrc:**
   ```bash
   grep "zoxide init" ~/.zshrc
   # Should show: eval "$(zoxide init zsh)"
   ```

3. **Reload configuration:**
   ```bash
   source ~/.zshrc
   ```

4. **Use directories to populate database:**
   ```bash
   # Navigate normally with cd
   cd ~/Documents
   cd ~/projects
   cd ~/Downloads

   # Check database
   zoxide query -l
   ```

5. **Manually add directories:**
   ```bash
   zoxide add /path/to/directory
   ```

6. **Check database location:**
   ```bash
   ls -la ~/.local/share/zoxide/
   ```

---

## Path and Environment Issues

### Command Not Found After Installation

**Symptoms:**
- "command not found" for newly installed tools
- Tools work in new terminal but not current one

**Solutions:**

1. **Reload shell configuration:**
   ```bash
   source ~/.zshrc
   # Or
   exec zsh
   ```

2. **Check if command exists:**
   ```bash
   which commandname
   # If empty, not in PATH
   ```

3. **Find command location:**
   ```bash
   # For Homebrew packages
   brew --prefix commandname

   # General search
   find /usr/local /opt/homebrew -name commandname 2>/dev/null
   ```

4. **Add to PATH manually:**
   ```bash
   # Add to ~/.zshrc
   export PATH="/opt/homebrew/bin:$PATH"
   source ~/.zshrc
   ```

5. **Verify PATH:**
   ```bash
   echo $PATH
   # Should include /opt/homebrew/bin or /usr/local/bin
   ```

---

### Homebrew Commands Not Available

**Symptoms:**
- `brew` command not found
- Homebrew installed but not accessible

**Solutions:**

1. **Check Homebrew installation:**
   ```bash
   # Apple Silicon
   ls /opt/homebrew/bin/brew

   # Intel
   ls /usr/local/bin/brew
   ```

2. **Initialize Homebrew in shell:**
   ```bash
   # Apple Silicon - add to ~/.zshrc
   eval "$(/opt/homebrew/bin/brew shellenv)"

   # Intel - add to ~/.zshrc
   eval "$(/usr/local/bin/brew shellenv)"

   source ~/.zshrc
   ```

3. **Verify PATH includes Homebrew:**
   ```bash
   echo $PATH | grep -o "homebrew"
   # Should show: homebrew
   ```

4. **Reinstall Homebrew:**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

---

### Duplicate PATH Entries

**Symptoms:**
- PATH contains same directory multiple times
- Slow command execution

**Solutions:**

1. **Check current PATH:**
   ```bash
   echo $PATH | tr ':' '\n'
   # Shows each PATH entry on separate line
   ```

2. **Remove duplicate entries from .zshrc:**
   ```bash
   # Edit ~/.zshrc and remove duplicate export PATH lines
   nano ~/.zshrc
   ```

3. **Use typeset to remove duplicates:**
   ```bash
   # Add to ~/.zshrc
   typeset -U PATH
   ```

4. **Clean reload:**
   ```bash
   source ~/.zshrc
   echo $PATH | tr ':' '\n'
   # Should show unique entries
   ```

---

## Shell Configuration Issues

### Changes Not Taking Effect

**Symptoms:**
- Edits to .zshrc don't apply
- Configuration seems ignored

**Solutions:**

1. **Reload configuration:**
   ```bash
   source ~/.zshrc
   ```

2. **Start fresh shell:**
   ```bash
   exec zsh
   ```

3. **Check for syntax errors:**
   ```bash
   zsh -n ~/.zshrc
   # No output = no errors
   # If errors shown, fix them
   ```

4. **Ensure editing correct file:**
   ```bash
   # Verify location
   echo $ZDOTDIR
   # Usually empty, meaning ~/.zshrc is used

   # Check which .zshrc is sourced
   ls -la ~/.zshrc
   ```

5. **Check for .zshenv overrides:**
   ```bash
   cat ~/.zshenv
   # May override .zshrc settings
   ```

---

### Slow Shell Startup

**Symptoms:**
- Terminal takes several seconds to open
- Prompt appears slowly

**Solutions:**

1. **Profile startup time:**
   ```bash
   # Add to top of ~/.zshrc
   zmodload zsh/zprof

   # Add to bottom
   zprof

   # Open new terminal to see profiling results
   ```

2. **Common culprits:**
   - NVM initialization (slow)
   - Homebrew completions
   - Too many Oh My ZSH plugins
   - Large history file

3. **Optimize NVM (if installed):**
   ```bash
   # Instead of loading NVM immediately, lazy load it
   # Replace in ~/.zshrc:
   export NVM_DIR="$HOME/.nvm"
   [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" --no-use
   ```

4. **Reduce plugins:**
   ```bash
   # Keep only essential plugins
   plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
   ```

5. **Enable Powerlevel10k instant prompt:**
   ```bash
   p10k configure
   # Select "yes" for instant prompt
   ```

6. **Trim history file:**
   ```bash
   # Limit history size in ~/.zshrc
   HISTSIZE=10000
   SAVEHIST=10000
   ```

---

### Configuration Conflicts

**Symptoms:**
- Settings override each other
- Unexpected behavior after installation

**Solutions:**

1. **Check for multiple configuration files:**
   ```bash
   ls -la ~/ | grep zsh
   # May show: .zshrc, .zshenv, .zprofile, .zlogin
   ```

2. **Loading order (understand precedence):**
   1. `.zshenv` (always)
   2. `.zprofile` (login shells)
   3. `.zshrc` (interactive shells)
   4. `.zlogin` (login shells, after .zshrc)

3. **Consolidate settings:**
   - Move most settings to `.zshrc`
   - Use `.zshenv` only for environment variables
   - Avoid `.zprofile` and `.zlogin` unless needed

4. **Backup and start fresh:**
   ```bash
   # Backup current config
   mv ~/.zshrc ~/.zshrc.backup

   # Reinstall
   ./install.sh

   # Manually merge important settings from backup
   ```

---

## Reset and Uninstall

### Resetting to Default Configuration

**Want to start fresh? Here's how:**

1. **Backup current configuration:**
   ```bash
   cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)
   cp ~/.p10k.zsh ~/.p10k.zsh.backup.$(date +%Y%m%d)
   ```

2. **Remove customizations:**
   ```bash
   rm ~/.zshrc
   rm ~/.p10k.zsh
   ```

3. **Reinstall:**
   ```bash
   ./install.sh
   ```

4. **Reconfigure Powerlevel10k:**
   ```bash
   p10k configure
   ```

---

### Removing Individual Modules

**Uninstall specific modules:**

1. **Using module uninstall command:**
   ```bash
   # Example: Uninstall fzf
   ./modules/utils/fzf.sh uninstall

   # Example: Uninstall bat
   ./modules/utils/bat.sh uninstall
   ```

2. **Manual uninstallation:**
   ```bash
   # Remove via Homebrew
   brew uninstall fzf

   # Remove configuration from .zshrc
   nano ~/.zshrc
   # Delete lines related to the tool

   # Reload
   source ~/.zshrc
   ```

3. **Remove ZSH plugins:**
   ```bash
   # Remove from plugins array in ~/.zshrc
   # Delete plugin directory
   rm -rf ~/.oh-my-zsh/custom/plugins/plugin-name
   ```

---

### Complete Uninstallation

**Remove everything installed by DR Custom Terminal:**

1. **Uninstall Oh My ZSH:**
   ```bash
   uninstall_oh_my_zsh
   ```

2. **Remove Powerlevel10k:**
   ```bash
   rm -rf ~/.oh-my-zsh/custom/themes/powerlevel10k
   rm ~/.p10k.zsh
   ```

3. **Uninstall Homebrew packages:**
   ```bash
   # List installed packages
   brew list

   # Uninstall specific packages
   brew uninstall fzf bat eza ripgrep fd zoxide delta lazygit btop neofetch

   # Uninstall fonts
   brew uninstall --cask font-meslo-lg-nerd-font
   ```

4. **Remove configuration:**
   ```bash
   # Backup first
   mv ~/.zshrc ~/.zshrc.old

   # Create minimal .zshrc
   echo "# Minimal ZSH configuration" > ~/.zshrc
   ```

5. **Optional: Uninstall Homebrew completely:**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
   ```

6. **Restore default shell (if desired):**
   ```bash
   # Switch back to bash
   chsh -s /bin/bash
   ```

---

## macOS-Specific Issues

### macOS Sonoma (14.x) Issues

**Permissions dialogs:**
- Grant Terminal full disk access: System Settings → Privacy & Security → Full Disk Access

**Slow first launch:**
- macOS may scan new binaries for malware
- Wait a few seconds on first run

### macOS Ventura (13.x) Issues

**Quarantine attributes:**
```bash
# If apps won't run
xattr -d com.apple.quarantine /path/to/app
```

### Apple Silicon vs Intel

**Path differences:**
- Apple Silicon: `/opt/homebrew`
- Intel: `/usr/local`

**Architecture check:**
```bash
uname -m
# arm64 = Apple Silicon
# x86_64 = Intel
```

---

## Frequently Asked Questions

### Q: Can I use this on Linux?
**A:** This toolkit is designed for macOS. For Linux, you would need to adapt the installer to use apt/yum instead of Homebrew and adjust paths accordingly.

### Q: Will this work with bash instead of zsh?
**A:** The installer is designed for ZSH. Most tools work with bash, but Oh My ZSH and Powerlevel10k are ZSH-specific.

### Q: Can I install only specific modules?
**A:** Yes! Run individual module installers directly:
```bash
./modules/utils/fzf.sh install
```

### Q: How do I update installed tools?
**A:** Use Homebrew:
```bash
brew update
brew upgrade
```

### Q: Will this slow down my terminal?
**A:** Minimally. With Powerlevel10k's instant prompt enabled, your terminal will typically be ready in milliseconds. The installer is optimized for performance.

### Q: Can I customize the Powerlevel10k theme?
**A:** Absolutely! Run `p10k configure` anytime to customize, or edit `~/.p10k.zsh` directly.

### Q: How much disk space does this use?
**A:** Approximately 500MB for a complete installation.

### Q: Can I run this multiple times?
**A:** Yes, the installer is idempotent. It will skip already-installed components and offer to reconfigure them.

### Q: What if I don't like a particular tool?
**A:** Uninstall it individually:
```bash
./modules/utils/toolname.sh uninstall
```

### Q: Are my existing dotfiles backed up?
**A:** Yes, Oh My ZSH creates `.zshrc.pre-oh-my-zsh` backup automatically.

### Q: How do I get help with specific tools?
**A:** Each tool has excellent documentation:
- Powerlevel10k: `p10k help`
- fzf: `man fzf`
- General: Check [docs/MODULES.md](MODULES.md)

### Q: Can I contribute new modules?
**A:** Yes! See [docs/MODULES.md](MODULES.md#creating-custom-modules) for the module template.

### Q: Will this interfere with my existing setup?
**A:** The installer checks for existing installations and offers to skip or reconfigure. Your existing configuration is preserved in backups.

---

## Still Having Issues?

If you're still experiencing problems:

1. **Check the log file:**
   ```bash
   cat .install.log
   ```

2. **Search existing issues:**
   - [GitHub Issues](https://github.com/yourusername/terminal-customization/issues)

3. **Create a new issue:**
   - Include macOS version
   - Include error messages
   - Include relevant log output
   - Describe steps to reproduce

4. **Get help from the community:**
   - [GitHub Discussions](https://github.com/yourusername/terminal-customization/discussions)

---

## Additional Resources

- [Main README](../README.md)
- [Module Documentation](MODULES.md)
- [Oh My ZSH Wiki](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Powerlevel10k FAQ](https://github.com/romkatv/powerlevel10k#faq)

---

**Last Updated:** 2026-07-11

For additional help, see the resources listed above.
