# Monasterium - Collaborative Archive

This repository contains the code for MOM-CA, the software that powers [Monasterium.net](https://www.monasterium.net/mom/home). The _readme_ file you are currently reading gives some basic information about how to run the software but for more information please consult the [wiki](https://github.com/icaruseu/mom-ca/wiki).

## Basics

MOM-CA is based on [eXist-db](http://exist-db.org), an XML database and application platform implemented in Java.

## Running directly

### Notes

- An admin user with the password specified in the build properties will be created by the installation process
- MOM-CA will rely on the [`sendmail`](https://en.wikipedia.org/wiki/Sendmail) command to send notifiaction emails. It has to be configured separately.
- The database content will be stored next to `mom.XRX` in a folder called `mom.XRX-data`.
- The system will be accessible at localhost:8181 (or using the configured port). To be reachable outside of the host system, a reverse proxy like nginx has to be configured.

### Prerequisites

- Linux server with Java > JDK 6, ant and git installed

### Installation

1. Clone the software with `git clone https://github.com/icaruseu/mom-ca.git mom.XRX`
2. Adapt [`build.properties.xml`](./build.properties.xml) to your needs ([details](https://github.com/icaruseu/mom-ca/wiki/Configuration)).
3. Build the software by using `ant install` in `mom.XRX`
4. Start MOM-CA by using `ant start`. It will be reachable under `localhost:8181` by default or with the port chosen by you in step #2.
5. You can restore a backup by using `ant restore-backup -Dbackup=[PATH_TO_BACKUP_FILE]`
6. In case you don't want to restore a backup you have to initialize the database and admin user account by using `ant initialize-new-database`.
7. Stop MOM-CA by using `ant stop`.

## Running with Docker

### Notes

- The database content is defined as a volume and is defined in the included `docker-compose.yml` as the `data` volume.
- The `./my` folder is mounted into the container to make direct changes to the source code easily possible. Changes still have to be compiled to be visible *inside* the database.
- The included `docker-compose.yml` can be extended by using [multiple configuration files](https://docs.docker.com/compose/extends/#multiple-compose-files).
- An admin user with the password specified in the environment parameters will be created in the image
- The system will be accessible at localhost:8181 (or using the configured port). To be reachable outside of the host system, a reverse proxy like nginx or traefik has to be configured.

### Prerequisites

- A server with docker installed. While Windows should be OK it is preferrable to use a Linux server or the [Windows Subsystem for Linux (WSL2)](https://docs.docker.com/docker-for-windows/wsl/).

### Build configuration

It is possible to set various parameters that MOM-CA will use when building a docker image. They are set in a `.env` file in the root code folder (see building instructions below). The possible parameters are:

| Name              | Default       | Mandatory | Description                                                 |
| ----------------- | ------------- | --------- | ----------------------------------------------------------- |
| BACKUP_TRIGGER    | 0 0 4 \* \* ? | no        | The definition for the backup trigger cronjob.              |
| CACHE_SIZE        | 256           | no        | The eXist cache size.                                       |
| COLLECTION_CACHE  | 256           | no        | The eXist collection cache size.                            |
| HTTPS_PORT        | 8443          | no        | The HTTPS port the internal eXist Jetty server listens to.  |
| HTTP_PORT         | 8181          | no        | The HTTP port the internal eXist Jetty server listens to.   |
| INIT_MEMORY       | 256           | no        | The initial memory available to the database.               |
| LUCENE_BUFFER     | 256           | no        | The eXist lucene buffer size.                               |
| MAIL_DOMAIN       |               | no        | The email sender domain                                     |
| MAIL_FROM_ADDRESS |               | no        | The 'From' email address                                    |
| MAIL_PASSWORD     |               | no        | The email server account password                           |
| MAIL_USER         |               | no        | The email server user account name                          |
| MAX_MEMORY        | 2048          | no        | The maximum memory available to the database.               |
| PASSWORD          |               | yes       | The admin password to set during build.                     |
| REVISION          |               | no        | Enable the versioning system. Currently has no effect.      |
| SERVER_NAME       | localhost     | no        | The name of the internal server.                            |
| SMTP_URL          |               | no        | The url of the smtp server to send mails with.              |
| USE_SSL           | false         | no        | Whether or not BetterFORM/eXist understands SSL connections |

### Building the image

1. Clone the software with `git clone https://github.com/icaruseu/mom-ca.git mom.XRX`
2. Create a .env file in the `mom.XRX` folder and add the desired parameters (for a list of possible values see above).
3. Build the docker image with `docker-compose build`

### Using the image

- A container using the image can be launched by using the `docker-compose up -d` command. If started for the first time, it will create a new data volume with an empty MOM-CA database, if starting an already existing container with data volume, the volume will not be changed by the process.
- The logs of the container can be viewed by using `docker logs -f momca`
- The container can be entered by using `docker exec -it momca /bin/bash`
- Files can be copied into the container using `docker cp [SRC_PATH] [CONTAINER:DEST_PATH]` and from inside the container by using `docker cp [CONTAINER:SRC_PATH] [DEST_PATH]`. This can be used for backup purposes.
- Ant targets defined in the MOM-CA code can be executed by using `docker exec -it momca ant [target]`
- A backup can be restored by using `docker exec -it momca ant restore-backup -Dbackup=[BACKUP_PATH_IN_CONTAINER]`
- The container can be stopped by using `docker-compose down` or, including all volumes, `docker-compose down -v` **WARNING: the `-v` flag deletes the database content without further warnings**

### Upgrading the database to new source code 

Whenever the MOM-CA source code is changed, either by pulling changes and building a new image or by changing the code in the local repository (it is mounted in the container by default), an additional step has to be taken to push the changes into the database and therefore making it visible to the application in the browser:

`docker exec -it momca ant compile-xrx-project`

**DISCLAIMER: Due to the nature of MOM-CA this can be somewhat unreliable and sometimes has to be done multiple times (until it works) ¯\\\_(ツ)\_/¯**

### Enable HTTPS

If so desired, the docker can be used in combination with a router like [Traefik](https://docs.traefik.io/) to enable HTTPS connection. To do this, the `docker-compose.yml` file has to be modified or a `docker-compose.override.yml` has to be created next to the main compose file. In addition to the specific setup needed to serve the content from the MOM-CA container (Traefik needs specific *Labels* to create a configuration for the container) valid key files need to be mounted at a specific location of the container:

- `[PATH_TO_CERTIFICATE.crt]:/opt/momca/ssl/certificate.crt:ro`
- `[PATH_TO_PRIVATE_KEY.key]:/opt/momca/ssl/privatekey.key:ro`

To enable the use of this files, the `USE_SSL` Environment parameter needs to be set to `true`.

*Note: this certificates will be embedded into MOM-CA on each container start so if the certificate needs to be renewed the container needs to be restarted for the new certificate to be used.*


The following shows a valid override file for MOM-CA using Traefik 2:

```yml
version: '3'

services:

  momca:
    volumes:
      - /ssl/momca.example.com/certificate.crt:/opt/momca/ssl/certificate.crt:ro
      - /ssl/momca.example.com/privatekey.key:/opt/momca/ssl/privatekey.key:ro
    networks:
      - traefik
    labels:
      - traefik.enable=true
      - traefik.http.routers.momca.entrypoints=http
      - traefik.http.routers.momca.rule=Host(`momca.example.com`)
      - traefik.http.middlewares.momca-https-redirect.redirectscheme.scheme=https
      - traefik.http.routers.momca.middlewares=momca-https-redirect
      - traefik.http.routers.momca-secure.entrypoints=https
      - traefik.http.routers.momca-secure.rule=Host(`momca.example.com`)
      - traefik.http.routers.momca-secure.tls=true
      - traefik.http.routers.momca-secure.tls.certresolver=http
      - traefik.http.routers.momca-secure.service=momca
      - traefik.http.services.momca.loadbalancer.server.port=8181
      - traefik.docker.network=traefik

networks:
  traefik:
    external: true
```

### Email

For a live server it is advisable to configure an smtp server so that MOM-CA can send notification emails. This can be achieved by setting the appropriate .env parameters (see above).
