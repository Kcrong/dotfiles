#!/bin/zsh

# Check and Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "Progress: Homebrew not found. Starting installation..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Notice: Homebrew is already installed."
fi

# Install Brew Packages
echo "Progress: Checking required Brew packages..."
brew install pure zsh-syntax-highlighting zsh-autosuggestions neovim

# Install Brew Casks
echo "Progress: Installing Brew Casks..."
brew install --cask karabiner-elements rectangle iterm2 1password scroll-reverser kiro-cli

# Set Paths and Variables
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
PLUGIN_DIR="$HOME/plugins"
BREW_PATH=$(brew --prefix)

# Determine the correct LS alias based on the OS once during installation
if [[ "$OSTYPE" == "darwin"* ]]; then
    LS_ALIAS_CMD='alias ls="ls -GF"'
    LL_ALIAS_CMD='alias ll="ls -lhGF"'
    LA_ALIAS_CMD='alias la="ls -lahGF"'
else
    LS_ALIAS_CMD='alias ls="ls --color=auto -F"'
    LL_ALIAS_CMD='alias ll="ls -lh --color=auto -F"'
    LA_ALIAS_CMD='alias la="ls -lah --color=auto -F"'
fi

# Ensure .zshrc and its parent directory exist
mkdir -p "$(dirname "$ZSHRC")"
if [ ! -f "$ZSHRC" ]; then
    echo "Notice: Creating new .zshrc at $ZSHRC"
    touch "$ZSHRC"
fi

# Download git.plugin.zsh
mkdir -p "$PLUGIN_DIR"
if [ ! -f "$PLUGIN_DIR/git.plugin.zsh" ]; then
    echo "Progress: Downloading git.plugin.zsh..."
    curl -sLo "$PLUGIN_DIR/git.plugin.zsh" https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh
else
    echo "Notice: git.plugin.zsh already exists."
fi

# Append configurations to .zshrc
echo "Progress: Verifying and updating $ZSHRC..."

# History settings
if ! grep -Fsq "# History settings" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# History settings" >> "$ZSHRC"
    echo "HISTSIZE=100000" >> "$ZSHRC"
    echo "SAVEHIST=100000" >> "$ZSHRC"
    echo "HISTFILE=~/.zsh_history" >> "$ZSHRC"
fi

# fpath configurations
if ! grep -Fsq "# fpath configurations" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# fpath configurations" >> "$ZSHRC"
    echo "fpath+=(\"$BREW_PATH/share/zsh/site-functions\")" >> "$ZSHRC"
fi

# Pure
if ! grep -Fsq "# Pure" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# Pure" >> "$ZSHRC"
    echo "autoload -U promptinit; promptinit" >> "$ZSHRC"
    echo "prompt pure" >> "$ZSHRC"
fi

# Auto completion with caching
if ! grep -Fsq "# Auto completion" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# Auto completion" >> "$ZSHRC"
    echo "autoload -Uz compinit" >> "$ZSHRC"
    echo 'if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then' >> "$ZSHRC"
    echo "  compinit" >> "$ZSHRC"
    echo "else" >> "$ZSHRC"
    echo "  compinit -C" >> "$ZSHRC"
    echo "fi" >> "$ZSHRC"
fi

# GIT plugin source
if ! grep -Fsq "# GIT plugin source" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# GIT plugin source" >> "$ZSHRC"
    echo "source \$HOME/plugins/git.plugin.zsh" >> "$ZSHRC"
fi

# Plugins (syntax-highlighting must be last)
if ! grep -Fsq "# Plugins" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# Plugins" >> "$ZSHRC"
    echo "source $BREW_PATH/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$ZSHRC"
    echo "source $BREW_PATH/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$ZSHRC"
fi

# LS colors and Aliases
if ! grep -Fsq "# LS colors and Aliases" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# LS colors and Aliases" >> "$ZSHRC"
    echo "export CLICOLOR=1" >> "$ZSHRC"
    echo "$LS_ALIAS_CMD" >> "$ZSHRC"
    echo "$LL_ALIAS_CMD" >> "$ZSHRC"
    echo "$LA_ALIAS_CMD" >> "$ZSHRC"
fi

# Editor configuration
if ! grep -Fsq "# Editor configuration" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# Editor configuration" >> "$ZSHRC"
    echo "export EDITOR=\"nvim\"" >> "$ZSHRC"
fi

# Neovim Aliases
if ! grep -Fsq "# Neovim Aliases" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# Neovim Aliases" >> "$ZSHRC"
    echo "alias vi=\"nvim\"" >> "$ZSHRC"
fi

# Kiro Cli Aliases
if ! grep -Fsq "# Kiro Cli Aliases" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# Kiro Cli Aliases" >> "$ZSHRC"
    echo "alias tt=\"kiro-cli --agent tutor\"" >> "$ZSHRC"
    echo "alias trt=\"kiro-cli --agent translator\"" >> "$ZSHRC"
fi

# Shell options
if ! grep -Fsq "# Shell Options" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# Shell Options" >> "$ZSHRC"
    echo "setopt AUTO_CD" >> "$ZSHRC"
    echo "setopt AUTO_PUSHD" >> "$ZSHRC"
    echo "setopt PUSHD_IGNORE_DUPS" >> "$ZSHRC"
    echo "setopt SHARE_HISTORY" >> "$ZSHRC"
    echo "setopt APPEND_HISTORY" >> "$ZSHRC"
    echo "setopt HIST_IGNORE_ALL_DUPS" >> "$ZSHRC"
    echo "setopt HIST_FIND_NO_DUPS" >> "$ZSHRC"
    echo "setopt HIST_REDUCE_BLANKS" >> "$ZSHRC"
    echo "setopt EXTENDED_GLOB" >> "$ZSHRC"
    echo "setopt NO_BEEP" >> "$ZSHRC"
fi

echo "---------------------------------------------------"
echo "Done: Environment setup completed successfully."
