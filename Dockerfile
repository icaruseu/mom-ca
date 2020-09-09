ARG BASE_CONTAINER=adoptopenjdk/openjdk8:latest
FROM $BASE_CONTAINER

LABEL maintainer="Daniel Jeller <djeller@nettek.at>"

USER root

ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"

ARG BACKUP_TRIGGER='0 0 4 * * ?'
ARG CACHE_SIZE=256
ARG COLLECTION_CACHE=256
ARG HTTPS_PORT=8443
ARG HTTP_PORT=8181
ARG INIT_MEMORY=256
ARG LUCENE_BUFFER=256
ARG MAIL_DOMAIN
ARG MAIL_FROM_ADDRESS
ARG MAIL_PASSWORD
ARG MAIL_USER
ARG MAX_MEMORY=2048
ARG PASSWORD
ARG REVISION=''
ARG SERVER_NAME='localhost'
ARG SMTP_URL
ARG USE_SSL=false

RUN apt-get update && apt-get -yq dist-upgrade &&\
  apt-get install -yq --no-install-recommends \
  ant \
  ca-certificates \
  git \
  lnav \
  msmtp \
  nano \
  sudo \
  unzip \
  vim \
  wget &&\
  rm -rf /var/lib/apt/lists/*

WORKDIR /opt/momca/mom.XRX

COPY . .

RUN rm build.properties.xml &&\
  echo '<?xml version="1.0" encoding="UTF-8"?>' >> build.properties.xml &&\
  echo '<!-- @author: Jochen Graf -->' >> build.properties.xml &&\
  echo '<XRX>' >> build.properties.xml &&\
  echo '<!-- ################################ XRX Project Settings ################################ -->' >> build.properties.xml &&\
  echo '<project-name>mom</project-name>' >> build.properties.xml &&\
  echo '<deploy>core/**,mom/**</deploy>' >> build.properties.xml &&\
  echo '<password>'"${PASSWORD}"'</password>' >> build.properties.xml &&\
  echo '<!-- ################################ Java Settings ################################ -->' >> build.properties.xml &&\
  echo '<java>' >> build.properties.xml &&\
  echo '<initmemory>'"${INIT_MEMORY}"'</initmemory>' >> build.properties.xml &&\
  echo '<maxmemory>'"${MAX_MEMORY}"'</maxmemory>' >> build.properties.xml &&\
  echo '</java>' >> build.properties.xml &&\
  echo '<!-- ################################ eXist Settings ################################ -->' >> build.properties.xml &&\
  echo '<exist>' >> build.properties.xml &&\
  echo '<cache-size>'"${CACHE_SIZE}"'</cache-size>' >> build.properties.xml &&\
  echo '<collection-cache>'"${COLLECTION_CACHE}"'</collection-cache>' >> build.properties.xml &&\
  echo '<lucene-buffer>'"${LUCENE_BUFFER}"'</lucene-buffer>' >> build.properties.xml &&\
  echo '<backup-cron-trigger>'"${BACKUP_TRIGGER}"'</backup-cron-trigger>' >> build.properties.xml &&\
  echo '<revision>'"${REVISION}"'</revision>' >> build.properties.xml &&\
  echo '</exist>' >> build.properties.xml &&\
  echo '<!-- ################################ Jetty Settings ################################ -->' >> build.properties.xml &&\
  echo '<jetty>' >> build.properties.xml &&\
  echo '<port>'"${HTTP_PORT}"'</port>' >> build.properties.xml &&\
  echo '<port-ssl>'"${HTTPS_PORT}"'</port-ssl>' >> build.properties.xml &&\
  echo '<servername>'"${SERVER_NAME}"'</servername>' >> build.properties.xml &&\
  echo '</jetty>' >> build.properties.xml &&\
  echo '</XRX>' >> build.properties.xml

RUN ant install &&\
  ant start &&\
  ant sleep-until-started &&\
  ant initialize-new-database &&\
  ant stop

VOLUME /opt/momca/mom.XRX-data

RUN mkdir -p /opt/momca/mom.XRX-data/export &&\
  mkdir -p /opt/momca/mom.XRX/localhost/webapp/WEB-INF/logs

ENV EXIST_HOME=/opt/momca/mom.XRX/localhost

# msmtp

RUN touch /etc/msmtprc &&\
  echo "defaults" >> /etc/msmtprc &&\
  echo "tls on" >> /etc/msmtprc &&\
  echo "tls_trust_file /etc/ssl/certs/ca-certificates.crt" >> /etc/msmtprc &&\
  echo "logfile /var/log/msmtp/msmtp.log" >> /etc/msmtprc &&\
  echo "account smtp" >> /etc/msmtprc &&\
  echo "auth on" >> /etc/msmtprc &&\
  echo "host ${SMTP_URL}" >> /etc/msmtprc &&\
  echo "port 587" >> /etc/msmtprc &&\
  echo "domain ${MAIL_DOMAIN}" >> /etc/msmtprc &&\
  echo "from ${MAIL_FROM_ADDRESS}" >> /etc/msmtprc &&\
  echo "user ${MAIL_USER}" >> /etc/msmtprc &&\
  echo "password ${MAIL_PASSWORD}" >> /etc/msmtprc &&\
  echo "account default : smtp" >> /etc/msmtprc &&\
  chmod 600 /etc/msmtprc

RUN ln -s /usr/bin/msmtp /usr/sbin/sendmail &&\
  ln -s /usr/bin/msmtp /usr/bin/sendmail &&\
  ln -s /usr/bin/msmtp /usr/lib/sendmail

# Logrotate

RUN mkdir /var/log/msmtp &&\
  touch /var/log/msmtp/msmtp.log &&\
  touch /etc/logrotate.d/msmtp &&\
  echo "/var/log/msmtp/*.log {" >> /etc/logrotate.d/msmtp &&\
  echo "rotate 12" >> /etc/logrotate.d/msmtp &&\
  echo "monthly" >> /etc/logrotate.d/msmtp &&\
  echo "compress" >> /etc/logrotate.d/msmtp &&\
  echo "missingok" >> /etc/logrotate.d/msmtp &&\
  echo "notifempty" >> /etc/logrotate.d/msmtp &&\
  echo "}" >> /etc/logrotate.d/msmtp

# Update jetty and betterforms config in case of ssl use

RUN if ${USE_SSL}; then \
  cd /opt/momca/mom.XRX/localhost/webapp/WEB-INF \
  ; perl -i -0pe 's#<!--\n\s+(<property name="httpclient.ssl.context" value="de.betterform.connector.http.ssl.KeyStoreSSLContext" description="Full classpath of SSLProtocolSocketFactory which should be used by httpclient."/>)\n-->#$1#g' betterform-config.xml \
  ; perl -i -0pe 's#<property name="httpclient.ssl.keystore.path" value="PATH-TO-KEYSTORE" description="Location of the keystore to be used by httpclient."/>#<property name="httpclient.ssl.keystore.path" value="/opt/momca/mom.XRX/localhost/tools/jetty/etc/KeyStore.jks" description="Location of the keystore to be used by httpclient."/>#g' betterform-config.xml \
  ; perl -i -0pe 's#<property name="httpclient.ssl.keystore.passwd" value="KEYSTORE-PASSWD" description="Password to unlock keystore."/>#<property name="httpclient.ssl.keystore.passwd" value="'${PASSWORD}'" description="Password to unlock keystore."/>#g' betterform-config.xml \ 
  ; fi

# Create entrypoint script

RUN echo '#!/bin/bash' >> /usr/local/bin/docker-entrypoint.sh &&\
  echo 'set -e' >> /usr/local/bin/docker-entrypoint.sh
  

RUN if ${USE_SSL}; then \
  echo 'cd /opt/momca' >> /usr/local/bin/docker-entrypoint.sh ; \
  echo 'rm -f KeyStore.jks' >> /usr/local/bin/docker-entrypoint.sh ; \
  echo 'keytool -genkey -keystore ./mom.XRX/localhost/tools/jetty/etc/KeyStore.jks -keyalg RSA -keysize 2048 -alias app -dname "cn=Unknown, ou=Unknown, o=Unknown, c=Unknown" -storepass '"${PASSWORD}"' -keypass '"${PASSWORD}" >> /usr/local/bin/docker-entrypoint.sh ; \
  echo 'openssl pkcs12 -export -nodes -out keystore.pkcs12 -in ./ssl/certificate.crt -inkey ./ssl/privatekey.key -passout pass:'"${PASSWORD}" >> /usr/local/bin/docker-entrypoint.sh ; \
  echo 'keytool -importkeystore -srckeystore keystore.pkcs12 -srcstoretype PKCS12 -destkeystore ./mom.XRX/localhost/tools/jetty/etc/KeyStore.jks -storepass '"${PASSWORD}"'  -srcstorepass '"${PASSWORD}"' -noprompt' >> /usr/local/bin/docker-entrypoint.sh ; \
  fi

RUN echo 'cd /opt/momca/mom.XRX' >> /usr/local/bin/docker-entrypoint.sh &&\
  echo 'ant start' >> /usr/local/bin/docker-entrypoint.sh &&\
  # echo 'ant sleep-until-started' >> /usr/local/bin/docker-entrypoint.sh &&\
  # echo 'curl -s http://localhost:${HTTP_PORT}/mom/home > /dev/null' >> /usr/local/bin/docker-entrypoint.sh &&\
  # echo 'ant compile-xrx-project' >> /usr/local/bin/docker-entrypoint.sh &&\
  echo 'tail -f ./localhost/webapp/WEB-INF/logs/exist.log -f ./localhost/webapp/WEB-INF/logs/xmlrpc.log -f ./localhost/webapp/WEB-INF/logs/restxq.log -f /var/log/msmtp/msmtp.log' >> /usr/local/bin/docker-entrypoint.sh &&\
  chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE ${HTTP_PORT} ${HTTPS_PORT}

HEALTHCHECK --interval=1m --timeout=10s \
  CMD curl -f http://localhost:${HTTP_PORT}/mom/home || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
