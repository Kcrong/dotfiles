#!/bin/bash

# Step 1: Move to the ~/Library directory and create the KeyBindings folder if it doesn't exist
cd ~/Library || exit
mkdir -p KeyBindings

# Step 2: Create the DefaultKeyBinding.dict file and add the specified content
cat <<EOL > KeyBindings/DefaultKeyBinding.dict
{
    "₩" = ("insertText:", "\`");
}
EOL

echo "DefaultKeyBinding.dict has been created and configured in ~/Library/KeyBindings."

