#!/usr/bin/env bash

# confirm that iTerm2 app's name is "iTerm" or "iTerm2"
osascript -e 'tell application "iTerm" to version' >/dev/null 2>&1 && app_name="iTerm" || app_name="iTerm2"

# choose files by using apple script
FILE=$(
    osascript <<EOF
tell application "$app_name"
    set selectedFiles to choose file \
        with multiple selections allowed \
        with prompt "Choose some files to send"
    set filePaths to ""
    repeat with theFile in selectedFiles
        set filePaths to filePaths & "\"" & POSIX path of theFile & "\" "
    end repeat
    return filePaths
end tell
EOF
)

# $FILE format(file name can have spaces):
# "/Users/xxx/Downloads/file1.txt" "/Users/xxx/Downloads/file 2.txt" "/Users/xxx/Downloads/file3.txt"
# echo $FILE

if [[ $FILE = "" ]]; then
    echo Cancelled.
    # Send ZModem cancel, \\x18 actually is \x18, it is hex for Ctrl-X
    echo -e \\x18\\x18\\x18\\x18\\x18
    sleep 1
    echo
    echo \# Cancelled transfer
else
    # send files to server by using sz
    eval "/usr/local/bin/sz --escape --binary --bufsize 4096 $FILE"
    sleep 1
    echo
    # string that split by space transform to array
    read -ra files <<<"$FILE"
    # print received files one by one
    for file in "${files[@]}"; do
        echo \# Received $file
    done
fi
