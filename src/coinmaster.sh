#!/bin/bash

source "$SRC_HOME/src/shared-functions.sh"
source "$SRC_HOME/.env"

DEFAULT_FORMAT='-column' # do sqlite .mode xxx to find all accepted formats
HEADER='-header' #-[no]header
LESS='--RAW-CONTROL-CHARS --chop-long-lines --shift=4 --quit-if-one-screen --no-init --tilde --LONG-PROMPT'

print_guidance() {
	echo 'coinmaster:
    cli > starts sqlite3 shell
    open > opens database in sqlitebrowser
    connect > invoke connection  manager
    transac > invoke transaction manager
    expense > invoke expenses manager
    new transac | log > inserts a transaction in coinmaster
    dump > dump database'
}

main() {

    case "$1" in

        '') print_guidance ;;
        cli | start) start_sqlite3 ;;
        gui | open) open_sqlitebrowser ;;
        new) shift ; route_new "$@" ;;
        log) "$transactions_manager" --new ;;
        tx | transac*) shift ; "$transactions_manager" "$@" ;;
        xp | *xpen*  ) shift ; "$expenses_manager" "$@" ;;
        dump | backup) dump_database ;;
        pending) execute_query "$pending_transactions" ;;
        *) echo 'nothing happened...' ;;

    esac

}

execute_query() {
    tmp=$(mktemp)
    sqlite3 "$coinmaster_location" '.headers on' '.mode tab' "$1" > $tmp
    tabcat $tmp
}

#FIXME:
dump_database() {
    sqlite3 "$coinmaster_location" <<EOF
.headers on
.output /home/ahmad/nexus/coin/coin.dump
.dump
EOF

echo "coin.db dumped to /home/ahmad/nexus/coin/coin.dump (i'm hardcoded FIX ME)"

}

open_sqlitebrowser() {
    nohup sqlitebrowser $coinmaster_location 2> /tmp/coinmaster.log &
}

route_new() {
    case "$1" in
        '') echo 'new what?' ;;
        transac*) "$transactions_manager" --new ;;
        *) echo "tf is $@. See $SRC_HOME" ;;
    esac
}

start_sqlite3() {
    sqlite3 "$coinmaster_location" -box "SELECT * FROM _main_"
    echo -e "SELECT FROM THE FOLLOWING:"
    sqlite3 "$coinmaster_location" .tables
    echo ''
    sqlite3 "$coinmaster_location" $HEADER $DEFAULT_FORMAT
}
