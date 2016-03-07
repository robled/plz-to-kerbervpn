#!/bin/bash

princ="$1"
kdc="$2"
declare down
retry_wait=0.5s
retry_max=2
scriptname=$(basename $0)
pidfile="/var/run/user/"$(id -u)"/${scriptname}-"$princ""
declare current_ticket

function check_tix {
    # true if kerberos ticket found
    if klist -l | grep "$princ" > /dev/null 2>&1; then
        echo ""$princ" ticket found."
        result="$princ"
    fi
}

function renew_tix {
    if kswitch -p "$tick" && kinit -R > /dev/null 2>&1; then
        echo ""$tick" ticket renewed."
    fi
}

function try_kdc {
    if [[ "$kdc" == "$down" ]]; then
        retry_count=$[$retry_count +1]
        echo "can't ping "$kdc"."
        echo "sleeping for "$retry_wait""
        sleep "$retry_wait"
    fi
    ping -c1 -W 1 -n "$kdc" > /dev/null 2>&1
    if [[ "$?" -eq 0 ]]; then
        echo "running kinit "$princ"..."
        xterm -e "until kinit "$princ";do true; done"
    else
        down="$kdc"
    fi
}

# lock it
# https://tobrunet.ch/2013/01/follow-up-bash-script-locking-with-flock/
exec 200>"$pidfile"
if ! flock -n 200; then
    echo 'already running'
    exit 1
fi
pid=$$
echo "$pid" 1>&200

readarray -t tix < <(klist -A | grep 'Default principal:' | awk '{print $3}')
if [ ! -z "$tix" ]; then
    current_ticket="${tix[0]}"
    echo "Active ticket = $current_ticket"
    for tick in "${tix[@]}"; do
        renew_tix "$tick"
    done
fi

until [[ "$princ" == "$result" ]] || [[ "$retry_count" -ge "$retry_max" ]]; do
    check_tix "$princ"
    if [[ "$result" != "$princ" ]]; then
        try_kdc "$kdc"
    fi
done

if [[ ! -z "$current_ticket" ]]; then
    echo "Switching to previously active ticket "$current_ticket""
    kswitch -p "$current_ticket"
fi

rm "$pidfile"
