FROM alpine:3.5

ARG IMAGE
ARG NAME
ARG AUTHOR
ARG URL
ARG BUILD_DATE
ARG BUILD_VERSION
ARG REPO_URL
ARG REPO_REF

LABEL maintainer=$AUTHOR \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.name=$NAME \
      org.label-schema.url=$URL \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url=REPO_URL \
      org.label-schema.vcs-ref=REPO_REF

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8"

# copy files
	COPY files/. /

# create directories
	RUN mkdir -p /scripts/pre-exec.d /scripts/pre-init.d

# alter permissions
	RUN chmod -R 755 /scripts

# update packages
	RUN apk update \
		&& apk upgrade

# add packages
	RUN apk --no-cache add mariadb mariadb-client pwgen

# cleanup
	RUN rm -rf /tmp/src /var/cache/apk/*

EXPOSE 3306

VOLUME /app/config
VOLUME /app/data

ENTRYPOINT ["/scripts/run.sh"]