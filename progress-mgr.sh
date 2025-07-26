#!/bin/sh

OUT_DIR=.  # size of this dir is monitored
STEP=1  # required size increase per period (bytes)
WAIT=1  # length of time between checks (could maybe use inotifywait to reduce cpu & disk)

reaction() {
    # Your code here; maybe kill the process and send you a text?
    echo 'bad program!'
    # return 0  # If you you have restated the program and this script can continue
    return 1  # If this script should exit
}

dir_size() {  # Get total size of dir (argument)
    echo $(du -sb "$@" | cut -f1)
}

check_progress() {  # Wait for the period to elapse then set the current size and required size
    sleep $WAIT
    cur_size=$(dir_size $OUT_DIR)
    req_size=$(expr $last_size + $STEP)
}

detect_stall() {  # Loop until the task should be continued stalled
    check_progress
    while [ $cur_size -ge $req_size ]; do
        last_size=$cur_size
        check_progress
    done
}

main_loop() {  # Wait for stall, react, optionally loop
    true
    while [ $? -eq 0 ]; do
        detect_stall
        reaction
    done
}

last_size=0
main_loop
