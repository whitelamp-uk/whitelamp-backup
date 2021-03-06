
rsn="/usr/bin/rsync"
tmp="$(dirname $0)/backup.tmp"
tmp2="$(dirname $0)/backup.tmp2"

if [ -f "$tmp" ]
then
    echo "Temporary file $tmp already exists" >&2
    exit 101
fi

touch "$tmp"
touch "$tmp2"

while read line
do

    # Parse config
    echo "$line" > "$tmp"
    if [ ! "$(echo $line)" ]
    then
        continue
    fi
    if [ "$(grep "^\s*#" "$tmp")" ]
    then
        continue
    fi
    source "$tmp"

    # Check config and make destination directory if necessary
    if [ ! "$t" ]
    then
        echo "Trash file not defined" >&2
        continue
    fi
    if [ ! -d "$s" ]
    then
        echo "Source \"$s\" is not found"
        continue
    fi
    if [ ! -d "$(dirname "$d")" ]
    then
        echo "Destination parent directory \"$(dirname "$d")\" not found" >&2
        continue
    fi
    if [ ! -d "$d" ]
    then
        mkdir "$d"
        if [ $? != 0 ]
        then
            echo "Destination directory \"$d\" could not be created" >&2
            continue
        fi
    fi

    # Log source files deleted (destination files are always kept)
    $rsn -rv $o --delete --dry-run "$s/" "$d/" | grep '^deleting\s' | cut -d' ' -f2- > "$tmp"
    touch "$s/$t"
    echo -n "" > "$tmp2"
    ts="$(date '+%FT%T')"
    while read present
    do
        while read past
        do
            found="$(echo "$past" | grep "$present")"
            if [ "$found" ]
            then
                echo "$found" >> "$tmp2"
                continue 2
            fi
        done < "$s/$t"
        echo "$present $ts" >> "$tmp2"
    done < "$tmp"
    echo "Last back-up received: $ts" > "$s/$t"
    cat "$tmp2" >> "$s/$t"

    # rsync
    echo $ts $rsn -r $o "$s/" "$d/"
    $rsn -r $o "$s/" "$d/"
    XDG_RUNTIME_DIR=$1 notify-send --urgency=low --category=transfer.complete --expire-time=4000 "Backed up" "$rsn -r $o $s/ $d/"

done < "$(dirname $0)/backup.cfg"


rm "$tmp"
rm "$tmp2"






