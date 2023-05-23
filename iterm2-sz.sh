#!/usr/bin/env bash

FILE=
# if first param is "dragfiles" then the second params is the path of the dropped file/folder
if [ "$1" = "dragfiles" ]; then
    # detect if the second param is a file
    if [ -f "$2" ]; then
        FILE=\"$2\"
    # detect if the second param is a folder
    elif [ -d "$2" ]; then
        while IFS='"' read -r -d '' file; do
            FILE+=" "\"$file\"
        done < <(find "$2" -type f -not -name ".DS_Store" -print0)
    fi

    # if $FILE is not empty, then we output rz, because the drag is directly dropped to the terminal interface of the logged-in server, so it is equivalent to using the drag and drop method to input rz, and you can get the drag and drop file path through this method
    if [ -n "$FILE" ]; then
        echo "rz"
    fi
fi

# if $FILE is empty, it means that no file/folder is dropped here, so pop up the file selection box
FILE2=${FILE##"\""}
FILE2=${FILE2%"\""}
if [[ $FILE = "" ]]; then
    separator="||||||||||"
    # confirm that iTerm2 app's name is "iTerm" or "iTerm2"
    osascript -e 'tell application "iTerm" to version' >/dev/null 2>&1 && app_name="iTerm" || app_name="iTerm2"

    # choose files by using apple script
    FILES=$(
        osascript <<EOF
tell application "$app_name"
    set selectedFiles to choose file \
        with multiple selections allowed \
        with prompt "Choose some files to send"
    set filePaths to ""
    set filePath to ""
    set filePaths2 to ""
    repeat with theFile in selectedFiles
        set filePath to POSIX path of theFile
        set filePaths to filePaths & "\"" & filePath & "\" "
        set filePaths2 to filePaths2 & filePath & "###"
    end repeat
    return filePaths & "$separator" & filePaths2
end tell
EOF
    )

    # replace $separator with \x1F
    FILES="${FILES//$separator/$'\x1F'}"

    # split $FILES by \x1F
    IFS=$'\x1F' read -ra PARTS <<<"$FILES"

    FILE=${PARTS[0]}
    FILE2=${PARTS[1]}

    # trim " " at the end of $FILE
    FILE=${FILE% }
    # trim "###“ at the end of $FILE2
    FILE2=${FILE2%###}
fi

# $FILE format(file name can have spaces):
# "/Users/xxx/Downloads/file1.txt" "/Users/xxx/Downloads/file 2.txt" "/Users/xxx/Downloads/file3.txt"

# current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
# echo "$current_date_time => $FILES" >>"$HOME/Downloads/dropped_files.txt"
# echo $FILE
# exit 0

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

    # Print received files
    if [[ $FILE2 == *"###"* ]]; then
        # replace "###" with \x1F
        FILE2="${FILE2//###/$'\x1F'}"

        # split $FILE2 by \x1F
        IFS=$'\x1F' read -ra PARTS <<<"$FILE2"

        echo \# "Received ${#PARTS[@]} files:"
        # print sent files one by one
        i=1
        for part in "${PARTS[@]}"; do
            filename=$(basename "$part")
            echo \# "- $i. "$filename
            ((i = i + 1))
        done
    else
        echo \# "Received 1 file:"
        filename=$(basename "$FILE2")
        echo \# "- 1. "$filename
    fi
fi
