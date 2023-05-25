#!/bin/bash
error() { echo $@ ; exit 1 ; }
id() { docker ps --format "table {{.ID}}\t{{.Names}}"| awk '$2 ~ /^'$1'/ {print $1}' ; }
usage() { echo "Usage: $@" ; exit 1; }

cmd_shell_landscape() { docker exec -it $(id landscape-landscape-1) /bin/bash -c "$@" ; }

cmd_shell_s6demo() { docker exec -it $(id landscape-s6demo-1) /bin/bash -c "$@" ; }

cmd_init() { cmd_shell_landscape 'apt-get update && apt-get install -y vim iputils-ping ldap-utils' ; }

cmd_register() { cmd_shell_s6demo 'landscape-config --silent --computer-title "My First Computer" --account-name standalone --url https://landscape-server/message-system --ping-url http://landscape-server/ping --ssl-public-key /etc/ssl/certs/landscape_server_ca.crt' ; }

cmd_run() { cd $THIS_DIR ; docker-compose up ; }

cmd_sh() {
    service=$1
    [ -z "$service" ] && service=landscape-landscape-1

    docker exec -it $(docker ps --format "table {{.ID}}\t{{.Names}}"| awk '$2 ~ /'${service}'/ {print $1}') /bin/bash
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
        register) cmd_register "$@" ;;
        run) cmd_run "$@" ;;
        sh) cmd_sh "$@" ;;
        test) cmd_test "$@" ;;
        *) usage "l [ make | run | sh | test ]" ;;
    esac
}

THIS_DIR=$( cd "$(dirname "$0")" >/dev/null 2>&1 ; cd ../ ; pwd )
THIS=$THIS_DIR/bin/l.sh

main "$@"