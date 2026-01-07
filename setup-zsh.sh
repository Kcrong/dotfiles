#!/bin/zsh

# 1. Check and Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "Progress: Homebrew not found. Starting installation..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Load Homebrew environment for the current session after installation
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Notice: Homebrew is already installed."
fi

# 2. Install Brew Packages
echo "Progress: Checking required Brew packages..."
brew install pure zsh-syntax-highlighting zsh-autosuggestions

# 3. Set Paths and Variables
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
PLUGIN_DIR="$HOME/plugins"
BREW_PATH=$(brew --prefix)

# 4. Download git.plugin.zsh
mkdir -p "$PLUGIN_DIR"
if [ ! -f "$PLUGIN_DIR/git.plugin.zsh" ]; then
    echo "Progress: Downloading git.plugin.zsh..."
    curl -sLo "$PLUGIN_DIR/git.plugin.zsh" https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh
else
    echo "Notice: git.plugin.zsh already exists."
fi

# 5. Append configurations to .zshrc (Line-by-line idempotency check)
echo "Progress: Verifying and updating $ZSHRC..."

# 1. fpath configurations
if ! grep -Fq "# 1. fpath configurations" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# 1. fpath configurations" >> "$ZSHRC"
    echo "fpath+=(\"$BREW_PATH/share/zsh/site-functions\")" >> "$ZSHRC"
fi

# 2. Pure
if ! grep -Fq "# 2. Pure" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# 2. Pure" >> "$ZSHRC"
    echo "autoload -U promptinit; promptinit" >> "$ZSHRC"
    echo "prompt pure" >> "$ZSHRC"
fi

# 3. Auto completion
if ! grep -Fq "# 3. Auto completion" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# 3. Auto completion" >> "$ZSHRC"
    echo "autoload -Uz compinit" >> "$ZSHRC"
    echo "compinit" >> "$ZSHRC"
fi

# 4. GIT plugin source
if ! grep -Fq "# 4. GIT plugin source" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# 4. GIT plugin source" >> "$ZSHRC"
    echo "source \$HOME/plugins/git.plugin.zsh" >> "$ZSHRC"
fi

# Plugins (Auto-suggestions & Syntax-highlighting)
if ! grep -Fq "# Plugins" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# Plugins" >> "$ZSHRC"
    echo "source $BREW_PATH/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$ZSHRC"
    echo "source $BREW_PATH/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$ZSHRC"
fi

echo "---------------------------------------------------"
echo "Done: Environment setup completed successfully."
echo "Run 'source ~/.zshrc' or open a new terminal to apply changes."
