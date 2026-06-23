FROM php:7.4-apache

# Configurar APT
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/10no-check-valid-until && \
    echo 'Acquire::Check-Date "false";' >> /etc/apt/apt.conf.d/10no-check-valid-until

# Instalar dependencias
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    html2ps \
    ghostscript \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpq-dev \
    libpng-dev \
    libxml2-dev \
    libonig-dev \
    curl \
    iputils-ping \
    netcat-openbsd \
    tzdata \
    zip \
    ca-certificates && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the System Timezone to Ecuador
ENV TZ="America/Guayaquil"

# Extensiones PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pgsql pdo pdo_pgsql gd mbstring xml soap

# Configurar Apache
RUN a2enmod rewrite && \
    a2enmod remoteip && \
    a2enmod headers

# Copy finanzas.gob.ec certificate into the container
COPY conf/wildcard-finanzas-gob-ec-ca.pem /tmp/

# Append it to the system-wide CA bundle
RUN cat /tmp/wildcard-finanzas-gob-ec-ca.pem >> /etc/ssl/certs/ca-certificates.crt && \
    rm /tmp/wildcard-finanzas-gob-ec-ca.pem

# Ensure PHP points to this file in php.ini
RUN echo 'curl.cainfo="/etc/ssl/certs/ca-certificates.crt"' > /usr/local/etc/php/conf.d/99-ca-certs.ini && \
    echo 'openssl.cafile="/etc/ssl/certs/ca-certificates.crt"' >> /usr/local/etc/php/conf.d/99-ca-certs.ini

WORKDIR /var/www/html
EXPOSE 80
CMD ["apache2-foreground"]

