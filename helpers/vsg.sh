#!/bin/sh

# Find an adjacent style definition
THIS_SCRIPT=$(readlink -f "$0")
STYLE=$(dirname "$THIS_SCRIPT")/vsg_style.yaml
if ! [ -f "$STYLE" ]
then
    echo "ERROR: Style definition \"$STYLE\" not found"
    exit 2
fi

# Compose a list of changed VHDL files
FILES=$(git diff main --name-only | grep '\.vhd$')
# For each one:
for FILE in $FILES
do
    # Ensure it exists (i.e. wasn't deleted in Git history)
    if [ -f "$FILE" ]
    then
        # If so, reformat it, passing through any extra arguments
        vsg -c "$STYLE" -f "$FILE" $@
    fi
done
