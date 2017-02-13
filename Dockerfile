FROM alpine:3.5

LABEL maintainer="Dirk Lüth <info@qoopido.com>" \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.name="Qoopido Docker MariaDB (Alpine)" \
      org.label-schema.url="https://github.com/dlueth/docker.alpine.mariadb" \
      org.label-schema.vcs-url="https://github.com/dlueth/docker.alpine.mariadb.git"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8"

# copy files
	COPY files/. /

# alter permissions
	RUN chmod -R 755 /scripts

# update packages
	RUN apk update \
		&& apk upgrade

# add packages
	RUN apk --no-cache add mariadb mariadb-client

# cleanup
	RUN rm -rf /tmp/* /var/cache/apk/*

EXPOSE 3306

VOLUME /app/config
VOLUME /app/data

ENTRYPOINT ["/scripts/run.sh"]