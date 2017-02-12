IMAGE  = qoopido/alpine-mariadb
tag   ?= develop

build:
	docker build --no-cache=true -t ${IMAGE}:${tag} .