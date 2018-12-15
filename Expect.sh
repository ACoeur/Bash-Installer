#!/usr/bin/expect -f

set timeout -1

spawn -noecho bash Main/Main.sh

match_max 100000

expect -exact "Enter password for new role: "
send -- "jyGfrU\r"

expect -exact "Enter it again: "
send -- "jyGfrU\r"

expect EOF
