#!/bin/sh

STORAGE="--datadir=/app/data/database --innodb_data_home_dir=/app/data/database"
SOCKET="--socket=/var/run/mysqld/mysqld.sock"
OPTIONS="--defaults-file=/config/my.cnf $STORAGE --general_log_file=/app/data/logs/general.log --log-error=/app/data/logs/error.log --slow-query-log-file=/app/data/logs/slow.log --aria-log-dir-path=/app/data/logs --pid-file=/var/run/mysqld/mysqld.pid $SOCKET --bind-address=0.0.0.0 --port=3306 --user=mysql"

if [ ! -d "/var/run/mysqld" ]; then
	mkdir -p /var/run/mysqld
	chown -R mysql:mysql /var/run/mysqld
fi

if [ ! -d "/app/data/database" ]; then
	mkdir -p /app/data/database
fi

if [ ! -d "/app/data/logs" ]; then
	mkdir -p /app/data/logs
fi

rm -rf /run/mysld
ln -s /var/run/mysqld /run/mysqld

if [ -d /app/data/database/mysql ]; then
	echo "[i] Found MariaDB database"
else
	echo "[i] Could not find MariaDB database"

	chown -R mysql:mysql /var/lib/mysql

	echo "[i] Initializing new database"
	/usr/bin/mysql_install_db ${STORAGE} > /dev/null
	/usr/bin/mysqld ${OPTIONS} &

	while !(mysqladmin ping > /dev/null 2>&1)
	do
		echo "[i] Waiting for MariaDB to start"
		sleep 1
	done

	if [ "$MARIADB_ROOT_PASSWORD" = "" ]; then
		MARIADB_ROOT_PASSWORD=`pwgen 16 1`

		echo "[i] Generated MariaDB root password: $MARIADB_ROOT_PASSWORD"
	fi

	MARIADB_DATABASE=${MARIADB_DATABASE:-""}
	MARIADB_USER=${MARIADB_USER:-""}
	MARIADB_PASSWORD=${MARIADB_PASSWORD:-""}

	sql=$(mktemp)

	echo "DROP DATABASE IF EXISTS test;" >> sql
	echo "DELETE FROM mysql.db WHERE Db='test' OR Db LIKE 'test_%';" >> sql
	echo "DELETE FROM mysql.user WHERE User='';" >> sql
	echo "GRANT ALL ON *.* to 'root'@'%' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD'; GRANT ALL ON *.* to 'root'@'localhost' IDENTIFIED BY '';" >> sql

    if [ "$MARIADB_DATABASE" != "" ]; then
	    echo "[i] Creating database: $MARIADB_DATABASE"
	    echo "CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\`;" >> sql

	    if [ "$MARIADB_USER" != "" ]; then
			echo "[i] Creating user: $MARIADB_USER with password $MARIADB_PASSWORD"
			echo "CREATE USER '$MARIADB_USER'@'%';" >> sql
			echo "GRANT ALL ON \`$MARIADB_DATABASE\`.* to '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';" >> sql
	    fi
	fi

	echo "FLUSH PRIVILEGES;" >> sql

	mysql -u root --password="" ${SOCKET} < sql

	/usr/bin/mysqladmin -uroot ${SOCKET} shutdown
fi

exec /usr/bin/mysqld ${OPTIONS} --console