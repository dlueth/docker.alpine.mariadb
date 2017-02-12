# recommended directory structure #
Like with my other containers I encourage you to follow a unified directory structure approach to keep things simple & maintainable, e.g.:

```
project root
  - docker_compose.yaml
  - config
    - mariadb
      - ...
  -data 
    - mariadb
```

# Example docker-compose.yaml #
```
db:
  image: qoopido/alpine-mariadb:latest
  ports:
   - "3306:3306"
  volumes:
   - ./config/mariadb:/app/config
   - ./data/mariadb:/app/data
```

# Or start container manually #
```
docker run -d -P -t -i -p 3306:3306 \
	-v [local path to config]:/app/config \
	-v [local path to data]:/app/data \
	--name db qoopido/alpine-mariadb:latest
```

# Credentials #
```root``` password is generated on first boot and will be shown in docker logs. From within the container ```root``` does not require a password.

If you specifiy environment variables for ```MARIADB_DATABASE```, ```MARIADB_USER``` and  ```MARIADB_PASSWORD``` the database and user will also get generated.

# Storage #
This container will auto-create basic databases in ```/app/data/database``` on first execution.

# Configuration #
Any config files under ```/app/config``` will be read in addition to the default database config. This can be used to overwrite the container's default maria configuration with a custom, project specific configuration.