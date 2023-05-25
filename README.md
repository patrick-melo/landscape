
Runs Canonical Landscape in docker.

# Quickstart
To start the service, clone this repo, cd into this directory and run the following command:

    docker-compose up

The service runs at:

    https://localhost/

At the welcome screen, provide the following credentials:

    Identity: user01
    Passphrase: password1

# Register a client
Use the following command to register the demo client:

    bin/l.sh register

# Resources
* [Landscape image](https://hub.docker.com/r/konvergence/landscape/)
* [OpenLDAP](https://hub.docker.com/r/bitnami/openldap/)
* [s6-overlay](https://github.com/just-containers/s6-overlay)
* [Landscape Manual Installation](https://ubuntu.com/landscape/docs/manual-installation)