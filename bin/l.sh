#!/bin/bash
error() { echo $@ ; exit 1 ; }
id() { docker ps --format "table {{.ID}}\t{{.Names}}"| awk '$2 ~ /^'$1'/ {print $1}' ; }
usage() { echo "Usage: $@" ; exit 1 ; }

cmd_debug() { bash -x $THIS "$@" ; }

cmd_ldap() {
    case $1 in
        install) cmd_ldap_install ;;
        list) cmd_ldap_list ;;
        test) cmd_ldap_test ;;
        *) usage "l ldap ['test']" ;;
    esac
}

cmd_ldap_install() { cmd_shell_server 'apt-get update && apt-get install -y vim iputils-ping ldap-utils' ;}

cmd_ldap_list() { cmd_shell_server 'ldapsearch -x -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w adminpassword -H ldap://openldap:1389/' ; }

cmd_ldap_test() {
    cmd_shell_server "ldapwhoami -H ldap://openldap:1389/ -D 'cn=admin,dc=example,dc=org' -x -w adminpassword"
    cmd_shell_server "ldapwhoami -H ldap://openldap:1389/ -D 'cn=user01,ou=users,dc=example,dc=org' -x -w password1"
    cmd_shell_server "ldapwhoami -H ldap://openldap:1389/ -D 'cn=user02,ou=users,dc=example,dc=org' -x -w password2"
}

cmd_make() {
    case "$1" in
        postgres) name=postgres ;;
        server) name=server ;;
        s6demo) name=s6demo ;;
        *) usage "l make [ 'server' | 's6demo' ]" ;;
    esac
    cd $THIS_DIR/$name
    pwd
    docker rmi docker 2>/dev/null
    docker build --no-cache -t $name .
}

cmd_register() { cmd_shell_s6demo 'landscape-config --silent --computer-title "My First Computer" --account-name standalone --url https://landscape-server/message-system --ping-url http://landscape-server/ping --ssl-public-key /etc/ssl/certs/landscape_server_ca.crt' ; }

cmd_run() { 
    case "$1" in
        server) name=server ;;
        s6demo) name=s6demo ;;
        *) name="" ;;
    esac
    cd $THIS_DIR/$name
    pwd
    docker-compose up  --remove-orphans
}

cmd_rmi() {
    docker images | awk '/landscape-s6demo/ || /bitnami\/openldap/ || /rabbitmq/ || /konvergence\/landscape/ || /konvergence\/postgres-plpython/ || /blacklabelops\/jobber/ {print $3}' | xargs docker rmi -f
}

cmd_sh() {
    service=$1
    [ -z "$service" ] && service=server

    docker exec -it $(id landscape-$service-1) /bin/bash
}

cmd_shell_server() { docker exec -it $(id landscape-server-1) /bin/bash -c "$@" ; }

cmd_shell_s6demo() { docker exec -it $(id landscape-s6demo-1) /bin/bash -c "$@" ; }

cmd_version() {
    format="%-16s%s\n"
    printf $format "Ubuntu:"    "$(cmd_shell_server 'lsb_release -ds')"
    printf $format "Landscape:" "$(cmd_shell_server 'apt list landscape-server 2>/dev/null' | grep -v Listing | sed -r 's/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g')"
    printf $format "Repo"       "$(cd $THIS_DIR ; git describe --dirty)"
    printf $format "Docker"       "$(docker --version)"
}

main() {
    CMD=$1 ; shift
    case "$CMD" in
        debug) cmd_debug "$@" ;;
        make) cmd_make "$@" ;;
        init) cmd_init "$@" ;;
        ldap) cmd_ldap "$@" ;;
        register) cmd_register "$@" ;;
        rmi) cmd_rmi "$@" ;;
        run) cmd_run "$@" ;;
        sh) cmd_sh "$@" ;;
        version|ver) cmd_version "$@" ;;
        *) usage "l [ 'make' | 'run' | 'sh' | 'test' ]" ;;
    esac
}

THIS_DIR=$( cd "$(dirname "$0")" >/dev/null 2>&1 ; cd ../ ; pwd )
THIS=$THIS_DIR/bin/l.sh

main "$@"