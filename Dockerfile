# Etapa 1: Construir a imagem do servidor web
FROM php:8.3-apache AS ocomon_web

RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6-dev libjpeg62-turbo-dev libpng-dev libwebp-dev libxpm-dev \
    libonig-dev libldap2-dev libzip-dev libssl-dev libc-client-dev libkrb5-dev \
    libcurl4-openssl-dev curl nano gettext && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install gd mysqli pdo pdo_mysql curl iconv mbstring ldap zip imap && \
    apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Declaração dos argumentos
ARG DB_HOST
ARG DB_NAME
ARG DB_USER
ARG DB_PASSWORD
ARG TIME_ZONE
ARG OCOMON_LINK
ARG FOLDER_NAME

# Configurar o fuso horário usando a variável de ambiente TIME_ZONE
RUN echo "date.timezone = ${TIME_ZONE}" > /usr/local/etc/php/conf.d/timezone.ini

# Apache ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Configurar o Apache para suportar index.php
RUN sed -i -e 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/apache2/mods-enabled/dir.conf

# Criar o arquivo 000-default.conf - permitir reescrita de URLs
RUN printf '<VirtualHost *:80>\n\
    <Directory /var/www/html>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ServerAdmin webmaster@localhost\n\
    DocumentRoot /var/www/html\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>\n' > /etc/apache2/sites-available/000-default.conf

# Ativar o site padrão do Apache
RUN a2ensite 000-default.conf

# Habilitar o mod_rewrite do Apache
RUN a2enmod rewrite

# Baixar e descompactar o Ocomon
RUN curl -L ${OCOMON_LINK} | tar -xz -C /var/www/html && \
    mv /var/www/html/${FOLDER_NAME}/* /var/www/html && \
    rm -Rf /var/www/html/${FOLDER_NAME}

# Substituir variáveis no arquivo config.inc.php-dist
RUN sed -i "s/define(\"SQL_USER\", \".*\");/define(\"SQL_USER\", \"${DB_USER}\");/g" /var/www/html/includes/config.inc.php-dist \
    && sed -i "s/define(\"SQL_PASSWD\", \".*\");/define(\"SQL_PASSWD\", \"${DB_PASSWORD}\");/g" /var/www/html/includes/config.inc.php-dist \
    && sed -i "s/define(\"SQL_SERVER\", \".*\");/define(\"SQL_SERVER\", \"${DB_HOST}\");/g" /var/www/html/includes/config.inc.php-dist \
    && sed -i "s/define(\"SQL_DB\", \".*\");/define(\"SQL_DB\", \"${DB_NAME}\");/g" /var/www/html/includes/config.inc.php-dist \
    && sed -i "s/define(\"DB_CCUSTO\", \".*\");/define(\"DB_CCUSTO\", \"${DB_NAME}\");/g" /var/www/html/includes/config.inc.php-dist \
    && cp /var/www/html/includes/config.inc.php-dist /var/www/html/includes/config.inc.php

# Aplicando permissões:
RUN chmod -R 755 /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Definir o diretório de trabalho
WORKDIR /var/www/html

# Expor a porta 8081 para o serviço web
EXPOSE 8081

CMD ["apache2-foreground"]

# Etapa 2: Construir a imagem do banco de dados - MariaDB
FROM mariadb:latest AS ocomon_db

# Instalar pacotes adicionais
RUN apt-get update && apt-get install -y curl tar

# Declaração dos argumentos
ARG OCOMON_LINK
ARG DB_INSTALL

# Baixar e preparar o arquivo SQL
RUN curl -L ${OCOMON_LINK} -o /tmp/ocomon.tar.gz \
    && mkdir -p /tmp/ocomon \
    && tar -xzf /tmp/ocomon.tar.gz -C /tmp/ocomon --strip-components=1 \
    && mv /tmp/ocomon/install/5.x/${DB_INSTALL} /docker-entrypoint-initdb.d/init.sql \
    && rm -rf /tmp/ocomon /tmp/ocomon.tar.gz

# Expor a porta 3306 para o serviço MySQL
EXPOSE 3306

# Etapa 3: Construir a imagem para o crontab
FROM alpine:latest AS ocomon_cron

# Instalar cron, PHP, e curl no contêiner Alpine
RUN apk add --update --no-cache \
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

# Declaração dos argumentos
ARG TZ_CRON

# Use printf para criar o arquivo mycrontab.tmp
RUN touch mycrontab.tmp \
 && printf "# m h  dom mon dow   command\n* * * * * curl http://ocomon_web/ocomon/open_tickets_by_email/service/getMailAndOpenTicket.php\n* * * * * curl http://ocomon_web/api/ocomon_api/service/sendEmail.php\n* * * * * curl http://ocomon_web/ocomon/service/update_auto_approval.php\n#* * * * * curl http://ocomon_web/ocomon/service/update_auto_close_due_inactivity.php\n" > mycrontab.tmp \ && crontab mycrontab.tmp \
 && rm -rf mycrontab.tmp

RUN sed -i "1 iCRON_TZ=\"${TZ_CRON}\"" /etc/crontabs/root
CMD ["/usr/sbin/crond", "-f", "-d", "0"]
