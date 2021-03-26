# ref.: https://websiteforstudents.com/how-to-install-ocs-inventory-server-on-ubuntu-18-04-16-04/

FROM ubuntu:20.04

RUN apt update \
    && apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository ppa:ondrej/php -y \
    && apt update \
    && apt install -y --no-install-recommends \
        apache2 \
        cpanminus \
        curl \
        git \
        libapache2-mod-perl2 \
        libapache2-mod-perl2-dev \
        libapache2-mod-php7.2 \
        libapache-dbi-perl \
        libcompress-zlib-perl \
        libdbd-mysql-perl \
        libdbi-perl \
        libio-compress-perl \
        libnet-ip-perl \
        libsoap-lite-perl \
        libxml-simple-perl \
        mysql-client \
        perl \
        php7.2 \
        php7.2-cli \
        php7.2-common \
        php7.2-curl \
        php7.2-gd \
        php7.2-gmp \
        php7.2-json \
        php7.2-mbstring \
        php7.2-mysql \
        php7.2-soap \
        php7.2-sqlite3 \
        php7.2-xml \
        php7.2-zip \
        php-pclzip \
        supervisor \
    && rm -rf /var/lib/apt/lists/*

# Extra perl modules 
# perl modules individual installation 
RUN apt update \
    && apt install -y --no-install-recommends build-essential \
    && cpanm --quiet --notest Apache2::SOAP \
    && cpanm --quiet --notest XML::Entities \
    && cpanm --quiet --notest Net::IP \
    && cpanm --quiet --notest Apache::DBI \
    && cpanm --quiet --notest Mojolicious \
    && cpanm --quiet --notest Switch \
    && cpanm --quiet --notest Plack::Handler \
    && cpanm --quiet --notest Archive::Zip \
    && apt remove --purge -y build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN cd /opt \
    && git clone https://github.com/OCSInventory-NG/OCSInventory-Server.git \
    && cd OCSInventory-Server \
    && git clone https://github.com/OCSInventory-NG/OCSInventory-ocsreports.git ocsreports \
    && cd ocsreports \
    && composer install \
    && cd /opt/OCSInventory-Server \
    && bash setup.sh

COPY etc /etc
COPY var /var
COPY opt /opt
#COPY usr /usr

# post config
RUN a2enconf ocsinventory-reports \
    && a2enconf z-ocsinventory-server \
    && a2enconf zz-ocsinventory-restapi \
    && chown -R www-data:www-data /var/lib/ocsinventory-reports \
    && chown -R www-data:www-data /usr/share/ocsinventory-reports/ocsreports \
    && cat /etc/apache2/ocs-envvars >> /etc/apache2/envvars

# logs to container log system
RUN rm /var/log/apache2/*.log \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log

# Replace database_server by hostname or ip of MySQL server for WRITE

# OCS SERVER
ENV OCS_DB_HOST database
# Replace 3306 by port where running MySQL server, generally 3306
ENV OCS_DB_PORT 3306
# Name of database
ENV OCS_DB_NAME ocsweb
ENV OCS_DB_LOCAL ocsweb
# User allowed to connect to database
ENV OCS_DB_USER ocs
# Password for user
ENV OCS_DB_PWD ocs

# OCS REST API
ENV PLACK_ENV=production
ENV MOJO_HOME='/usr/local/share/perl/5.30.0'
ENV MOJO_MODE='production'
#ENV MOJO_MODE='deployment'
ENV OCS_DB_SSL_ENABLED=0
#ENV OCS_DB_SSL_CLIENT_KEY='';
#ENV OCS_DB_SSL_CLIENT_CERT='';
#ENV OCS_DB_SSL_CA_CERT='';
ENV OCS_DB_SSL_MODE='SSL_MODE_PREFERRED'

CMD supervisord -c /etc/supervisor/supervisord.conf