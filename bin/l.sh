#!/bin/bash
error() { echo $@ ; exit 1 ; }
usage() { echo "Usage: $@" ; exit 1; }

cmd_shell() { docker exec -it $(docker ps --format "table {{.ID}}\t{{.Names}}"| awk '$2 ~ /^landscape-landscape-1/ {print $1}') /bin/bash -c "$@" ; }

cmd_init() {
    cmd_shell "apt-get update && apt-get install -y vim iputils-ping ldap-utils"
    #cmd_shell 'echo "172.20.0.4 ldapserver.local.lan" >> /etc/hosts'
}

cmd_run() { cd $THIS_DIR ; docker-compose up ; }

cmd_sh() {
    service=$1
    [ -z "$service" ] && service=landscape-landscape-1

    docker exec -it $(docker ps --format "table {{.ID}}\t{{.Names}}"| awk '$2 ~ /^'${service}'/ {print $1}') /bin/bash
}

cmd_test() { 
    if [ -z $1 ] ; then 
        test="test.TestTransactions"
    else
        test="test.TestTransactions.$1"
    fi
    cmd_exec "python3 -m unittest $test"; 
}

main() {
    CMD=$1 ; shift
    case "$CMD" in
        init) cmd_init "$@" ;;
        run) cmd_run "$@" ;;
        sh) cmd_sh "$@" ;;
        test) cmd_test "$@" ;;
        *) usage "l [ make | run | sh | test ]" ;;
    esac
}

THIS_DIR=$( cd "$(dirname "$0")" >/dev/null 2>&1 ; cd ../ ; pwd )
THIS=$THIS_DIR/bin/l.sh

main "$@"