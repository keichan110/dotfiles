# Do everything.
all: init link defaults brew git

# Set initial preference.
init:
	.bin/init.sh

# Link dotfiles.
link:
	.bin/link.sh

# Set macOS system preferences.
defaults:
	.bin/defaults.sh

# Install macOS applications.
brew:
	.bin/brew.sh

# Setup git alias
git:
	.bin/git.sh