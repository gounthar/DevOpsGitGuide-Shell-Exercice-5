# This Dockerfile is used to create a custom Gitpod workspace image.
# Gitpod is a service that provides ready-to-code development environments in the cloud.

# The base image is gitpod/workspace-python, which includes a full development environment.
FROM gitpod/workspace-python

# Switch to the root user to have the necessary permissions for the following operations.
USER root

# Install cron, mariadb-server and tree packages.
# Cron is a time-based job scheduler in Unix-like operating systems.
# MariaDB is a community-developed, commercially supported fork of the MySQL relational database management system.
# Tree is a recursive directory listing program that produces a depth-indented listing of files.
# The apt-get update command is used to download package information from all configured sources.
# The apt-get install command is used to install the specified packages.
RUN apt-get update && apt-get install -y cron mariadb-server mariadb-client tree

# Secure the MariaDB installation
# The debconf-set-selections command is used to pre-answer questions asked during the installation of mariadb-server.
# The root password for the MariaDB installation is set to 'root'.
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections && \
    apt-get install -y mariadb-server

# Create a test database and user
# The MariaDB configuration file is modified to bind to all interfaces.
RUN echo "[mysqld]\n\
bind-address = 0.0.0.0" > /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy the setup.sql file to the /docker-entrypoint-initdb.d/ directory in the Docker image.
# This script will be executed when the MariaDB service starts.
COPY setup.sql /docker-entrypoint-initdb.d/

# Copy the start-mariadb.sh script to the Docker image.
# This script starts the MariaDB service, waits for it to start, and then executes the setup.sql script.
COPY start-mariadb.sh /start-mariadb.sh

# Install ngrok
# ngrok is a cross-platform application that enables developers to expose a local development server to the Internet with minimal effort.
# The application captures all traffic for detailed inspection and replay.
# The curl command is used to download the ngrok.asc file from the ngrok-agent.s3.amazonaws.com server.
# The tee command is used to write the output of the curl command to the /etc/apt/trusted.gpg.d/ngrok.asc file.
# The echo command is used to add the ngrok-agent.s3.amazonaws.com server to the list of apt sources.
# The apt update command is used to download package information from all configured sources.
# The apt install command is used to install the ngrok package.
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
 | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
 && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
 | sudo tee /etc/apt/sources.list.d/ngrok.list \
 && sudo apt update \
 && sudo apt install ngrok

# Run the start-mariadb.sh script when the Docker container starts.
# This script starts the MariaDB service, waits for it to start, and then executes the setup.sql script.
CMD ["/start-mariadb.sh"]
