# git_scripts

### $HOME/.gitattributes
```
go.sum -diff
*_mock.go -diff
```

### $HOME/.gitignore
```
.idea/
gitdiff
.DS_Store
```

### $HOME/.gitconfig
```
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
```
