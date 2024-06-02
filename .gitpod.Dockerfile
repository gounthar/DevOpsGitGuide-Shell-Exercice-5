# This Dockerfile is used to create a custom Gitpod workspace image.
# Gitpod is a service that provides ready-to-code development environments in the cloud.

# The base image is gitpod/workspace-python, which includes a full development environment.
FROM gitpod/workspace-python

# Switch to the root user to have the necessary permissions for the following operations.
USER root

# Install cron and tree packages.
# Cron is a time-based job scheduler in Unix-like operating systems.
# Tree is a recursive directory listing program that produces a depth-indented listing of files.
# The apt-get update command is used to download package information from all configured sources.
# The apt-get install command is used to install the specified packages.
RUN apt-get update && apt-get install -y cron mariadb-server tree

# Start the cron service.
# The service command is used to run a System V init script.
RUN service cron start

# Secure the MariaDB installation
# The debconf-set-selections command is used to pre-answer questions asked during the installation of mariadb-server.
# The root password for the MariaDB installation is set to 'root'.
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections && \
    apt-get install -y mariadb-server

# Create a test database and user
# The MariaDB configuration file is modified to skip the grant tables and bind to all interfaces.
# The setup.sql script, which creates a test database and user, is copied to the docker-entrypoint-initdb.d directory.
# The docker-entrypoint-initdb.d directory is a special directory that MySQL checks at startup and executes any scripts found.
RUN echo "[mysqld]\n\
skip-grant-tables\n\
bind-address = 0.0.0.0" > /etc/mysql/mariadb.conf.d/50-server.cnf

COPY setup.sql /docker-entrypoint-initdb.d/

RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
	| sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
	&& echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
	| sudo tee /etc/apt/sources.list.d/ngrok.list \
	&& sudo apt update \
	&& sudo apt install ngrok
