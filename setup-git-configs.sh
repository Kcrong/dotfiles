#!/bin/zsh

# Set file paths
GITATTRIBUTES="$HOME/.gitattributes"
GITIGNORE="$HOME/.gitignore"
GITCONFIG="$HOME/.gitconfig"

# Function to backup existing files
backup_file() {
    local FILE=$1
    if [ -f "$FILE" ]; then
        echo "Notice: $FILE already exists. Backing up to $FILE.bak"
        mv "$FILE" "$FILE.bak"
    fi
}

echo "Progress: Starting Git configuration setup..."

# Setup .gitattributes
backup_file "$GITATTRIBUTES"
echo "Progress: Creating $GITATTRIBUTES..."
cat << 'EOF' > "$GITATTRIBUTES"
go.sum -diff
*_mock.go -diff
package-lock.json -diff
pnpm-lock.yaml -diff
*.svg -diff
EOF

# Setup .gitignore
backup_file "$GITIGNORE"
echo "Progress: Creating $GITIGNORE..."
cat << 'EOF' > "$GITIGNORE"
.idea/
gitdiff
.DS_Store
EOF

# Setup .gitconfig
backup_file "$GITCONFIG"
echo "Progress: Creating $GITCONFIG..."
cat << 'EOF' > "$GITCONFIG"
[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true

[pull]
	rebase = true

[column]
	ui = auto

[branch]
	sort = -committerdate

[tag]
	sort = version:refname

[init]
	defaultBranch = main

[diff]
	algorithm = histogram
	colorMoved = plain
	mnemonicPrefix = true
	renames = true

[push]
	default = simple
	autoSetupRemote = true
	followTags = true

[fetch]
	prune = true
	pruneTags = true
	all = true

[help]
	autocorrect = prompt

[commit]
	verbose = true

[rerere]
	enabled = true
	autoupdate = true

[rebase]
	autoSquash = true
	autoStash = true
	updateRefs = true

[core]
	fsmonitor = true
	untrackedCache = true
	attributesfile = ~/.gitattributes
	excludesFile = ~/.gitignore

[merge]
	# (just 'diff3' if git version < 2.3)
	conflictstyle = zdiff3 
EOF

echo "---------------------------------------------------"
echo "Done: Git configurations have been applied."
echo "Existing files were backed up as .bak where applicable."
