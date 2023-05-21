#!/usr/bin/env bash

# confirm that iTerm2 app's name is "iTerm" or "iTerm2"
osascript -e 'tell application "iTerm" to version' >/dev/null 2>&1 && app_name="iTerm" || app_name="iTerm2"

# confirm that choose folder or not
# you can set CHOOSE_FOLDER=true in your ~/.bashrc(not .zshrc or config.fish) to enable this feature
source "$HOME/.bashrc"
echo $CHOOSE_FOLDER >"$HOME/Downloads/choose_folder.txt"
if [ -n "$CHOOSE_FOLDER" ] && [ "$CHOOSE_FOLDER" = true ]; then
    # choose folder by using apple script
    FILE=$(
        osascript <<EOF
tell application "$app_name"
    set thefile to choose folder with prompt "Files save to:"
    set thefile to POSIX path of theFile
end tell
EOF
    )
else
    # fixed folder
    FILE="$HOME/Downloads/"
fi

# $FILE format(folder name can have spaces):
# /Users/xxx/Downloads/folder
# /Users/xxx/Downloads/fol der
# echo $FILE

if [[ $FILE = "" ]]; then
    echo Cancelled.
    # Send ZModem cancel
    echo -e \\x18\\x18\\x18\\x18\\x18
    sleep 1
    echo
    echo \# Cancelled transfer
else
    cd "$FILE"
    # receive files from server by using rz
    /usr/local/bin/rz -E -e -b --bufsize 4096
    sleep 1
    echo
    echo
    echo \# Files have been Sent to \-\> "$FILE"
fi
