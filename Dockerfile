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

WORKDIR /var/www/html
EXPOSE 80
CMD ["apache2-foreground"]

