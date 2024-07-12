# Etapa 1: Construir a imagem do servidor web
FROM php:8.3-apache AS ocomon_web

ENV OCOMON_LINK="https://sourceforge.net/projects/ocomonphp/files/OcoMon_5.0/Final/ocomon-5.0.tar.gz/download"
ENV FOLDER_NAME="ocomon-5.0"

RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    libonig-dev \
    libldap2-dev \
    libzip-dev \
    libssl-dev \
    libc-client-dev \
    libkrb5-dev \
    libcurl4-openssl-dev \
    curl \
    nano \
    gettext && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install gd mysqli pdo pdo_mysql curl iconv mbstring ldap zip imap && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configurar o timezone do PHP para o Brasil
RUN echo "date.timezone = America/Porto_Velho" > /usr/local/etc/php/conf.d/timezone.ini

# Apache ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
# Configurar o Apache para suportar index.php
RUN sed -i -e 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/apache2/mods-enabled/dir.conf
# Copiar o arquivo de configuração do Apache para permitir reescrita de URLs
COPY ./assets/000-default.conf /etc/apache2/sites-available/000-default.conf
# Habilitar o mod_rewrite do Apache
RUN a2enmod rewrite

# Baixar e configurar o Ocomon
RUN curl -L ${OCOMON_LINK} | tar -xz -C /var/www/html && \
#RUN tar -xzvf ./assets/ocomon-5.0.tar.gz -C /var/www/html && \
    mv /var/www/html/${FOLDER_NAME}/* /var/www/html && \
    rm -Rf /var/www/html/${FOLDER_NAME}

# Copiar o arquivo de configuração do Ocomon config.inc.php-dist:
COPY ./assets/config.inc.php-dist /var/www/html/includes/config.inc.php-dist

# Substituir variáveis no arquivo config.inc.php-dist e mover para config.inc.php
RUN envsubst < /var/www/html/includes/config.inc.php-dist > /var/www/html/includes/config.inc.php

# Aplicando permissões:
RUN chmod -R 755 /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Definir o diretório de trabalho
WORKDIR /var/www/html

# Criar a pasta docker-entrypoint-initdb.d
RUN mkdir -p /docker-entrypoint-initdb.d

# Copiar o arquivo SQL de inicialização do banco de dados para o diretório apropriado
RUN cp /var/www/html/install/5.x/01-DB_OCOMON_5.x-FRESH_INSTALL_STRUCTURE_AND_BASIC_DATA.sql /docker-entrypoint-initdb.d/init.sql

# Expor a porta 8081 para o serviço web
EXPOSE 8081

CMD ["apache2-foreground"]

# Etapa 2: Construir a imagem do banco de dados MySQL
FROM mysql:5.7 AS ocomon_db

ENV MYSQL_ROOT_PASSWORD=your_root_password
ENV MYSQL_DATABASE=ocomon
ENV MYSQL_USER=ocomon_user
ENV MYSQL_PASSWORD=senha_ocomon_mysql

# Copiar o arquivo SQL de inicialização para o contêiner MySQL
COPY --from=ocomon_web /docker-entrypoint-initdb.d/init.sql /docker-entrypoint-initdb.d/init.sql

# Expor a porta 3306 para o serviço MySQL
EXPOSE 3306

# Etapa 3: Construir a imagem para cron
FROM alpine:3.18 AS ocomon_cron

# Instalar cron, PHP, e curl no contêiner Alpine
RUN apk add --no-cache \
    php \
    php-cli \
    php-mbstring \
    php-ldap \
    php-imap \
    php-curl \
    php-gd \
    php-pdo \
    php-mysqli \
    php-sqlite3 \
    php-phar \
    php-zip \
    curl \
    openrc \
    && rm -rf /var/cache/apk/*

# Adicionar entrypoint script
COPY ./assets/start_cron.sh /start_cron.sh
RUN chmod +x /start_cron.sh

# Copiar o arquivo de crontab
COPY ./assets/mycrontab /etc/crontabs/root
RUN chmod 0644 /etc/crontabs/root

ENTRYPOINT ["/start_cron.sh"]
