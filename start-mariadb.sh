#!/bin/bash
service mariadb start

# Wait for MariaDB to start
while ! mysqladmin ping -s; do
    sleep 1
done

mysql -u root --password=password < $PWD/setup.sql

# Connect to the 'testdb' database
# mysql -u root -D testdb

bash
