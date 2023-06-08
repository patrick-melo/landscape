
Runs Canonical Landscape in docker.

# Quickstart
To start the service, clone this repo, cd into this directory and run the following command:

    docker-compose up

The service runs at:

    https://localhost/

At the welcome screen, provide the following credentials:

    Identity: user1
    Passphrase: password

# Register a client
Use the following command to register the demo client:

    bin/l.sh register

# Version
The following information can be retrieved with `bin/l.sh ver`.

    Client:         18.01-0ubuntu13
    Landscape:      19.01-0ubuntu2
    Ubuntu:         Ubuntu 18.04.2 LTS
    Docker          Docker version 23.0.5, build bc4487a
    Repo            v1.0.0-9-g35f15a9-dirty

# Resources
* [Landscape image](https://hub.docker.com/r/konvergence/landscape/)
* [OpenLDAP](https://hub.docker.com/r/bitnami/openldap/)
* [s6-overlay](https://github.com/just-containers/s6-overlay)
* [Landscape Manual Installation](https://ubuntu.com/landscape/docs/manual-installation)