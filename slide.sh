#!/bin/bash
function slide() {
    local -r TPUT=$(type -p tput)
    [ -x "$TPUT" ] || exit 1
    local -r IFS=''
    local -r MESSAGE=${1:-<Enter> Next slide | <ctrl+c> Quit}
    local -ri COLS=$($TPUT cols)
    local -ri ROWS=$($TPUT lines)
    local -i CENTER=0
    local -i LINENUM=0
    local -i REVEAL=0

    trap "$TPUT clear" 0
    $TPUT clear

    while read LINE; do
        [ "$LINE" == '!!center' ] && CENTER=1 && continue
        [ "$LINE" == '!!nocenter' ] && CENTER=0 && continue
        [ "$LINE" == '!!pause' ] && read -s < /dev/tty && continue
        [ "$LINE" == '!!sep' ] && printf -vLINE "%${COLS}s" '' && LINE=${LINE// /-}
        [ "$LINE" == '!!reveal' ] && REVEAL=1 && continue
        [ "$LINE" == '!!noreveal' ] && REVEAL=0 && continue
        [ $CENTER -eq 1 ] && $TPUT cup $LINENUM $((($COLS-${#LINE})/2)) || $TPUT cup $LINENUM 0
        if [ $REVEAL -eq 1 ]; then
            for ((i=0;i<${#LINE};i++)); do echo -n "${LINE:$i:1}" && sleep 0.02; done
            echo
        else
            printf "%s\n" "$LINE"
        fi
        $TPUT cup $ROWS $COLS && let LINENUM++
    done
    $TPUT cup $ROWS $((($COLS-1)-${#MESSAGE})) && printf "$MESSAGE"
    read -s < /dev/tty
}
