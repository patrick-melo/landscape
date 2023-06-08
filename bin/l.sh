#!/bin/bash
error() { echo $@ ; exit 1 ; }
id() { docker ps --format "table {{.ID}}\t{{.Names}}"| awk '$2 ~ /^'$1'/ {print $1}' ; }
usage() { echo "Usage: $@" ; exit 1 ; }

cmd_clean() {
    echo "=> Remove docker images"
    docker images | awk '/blacklabelops\/jobber/ || /rabbitmq/ || /konvergence\/landscape/ || /konvergence\/postgres-plpython/ || /bitnami\/openldap/ || /landscape-s6demo/ {print $3}' | xargs docker rmi -f
    
    echo "=> Prune containers"
    docker container prune --force >/dev/null
    
    echo "=> Remove docker volumes"
    for x in landscape-ssl landscape-data postgres-data landscape-config openldap_data ; do
        docker volume rm landscape_$x >/dev/null 2>&1
    done
}

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
    cmd_shell_server "ldapwhoami -H ldap://openldap:1389/ -D 'cn=admin,dc=example,dc=org' -x -w password"
    cmd_shell_server "ldapwhoami -H ldap://openldap:1389/ -D 'cn=user1,ou=users,dc=example,dc=org' -x -w password"
    cmd_shell_server "ldapwhoami -H ldap://openldap:1389/ -D 'cn=user2,ou=users,dc=example,dc=org' -x -w password"
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

cmd_sh() {
    service=$1
    [ -z "$service" ] && service=server

    docker exec -it $(id landscape-$service-1) /bin/bash
}

cmd_shell_server() { docker exec -it $(id landscape-server-1) /bin/bash -c "$@" ; }

cmd_shell_s6demo() { docker exec -it $(id landscape-s6demo-1) /bin/bash -c "$@" ; }

cmd_version() {
    format="%-16s%s\n"
    printf $format "Client:"    "$(cmd_shell_s6demo 'landscape-config --version')"
    printf $format "Landscape:" "$(cmd_shell_server 'dpkg -s  landscape-server'| awk '/Version/ {print $2}')"
    printf $format "Ubuntu:"    "$(cmd_shell_server 'lsb_release -ds')"
    printf $format "Docker"     "$(docker --version)"
    printf $format "Repo"       "$(cd $THIS_DIR ; git describe --dirty)"
}

main() {
    CMD=$1 ; shift
    case "$CMD" in
        clean) cmd_clean "$@" ;;
        debug) cmd_debug "$@" ;;
        make) cmd_make "$@" ;;
        init) cmd_init "$@" ;;
        ldap) cmd_ldap "$@" ;;
        register|reg) cmd_register "$@" ;;
        run) cmd_run "$@" ;;
        sh) cmd_sh "$@" ;;
        version|ver) cmd_version "$@" ;;
        *) usage "l [ 'make' | 'run' | 'sh' | 'test' ]" ;;
    esac
}

THIS_DIR=$( cd "$(dirname "$0")" >/dev/null 2>&1 ; cd ../ ; pwd )
THIS=$THIS_DIR/bin/l.sh

main "$@"