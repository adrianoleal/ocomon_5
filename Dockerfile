# Etapa 1: Construir a imagem do banco de dados MySQL
FROM mysql:5.7 as ocomon_db

ENV MYSQL_ROOT_PASSWORD=your_root_password
ENV MYSQL_DATABASE=ocomon
ENV MYSQL_USER=ocomon_user
ENV MYSQL_PASSWORD=ocomon_password

# Copiar o arquivo SQL de inicialização para o contêiner MySQL
COPY ./docker-entrypoint-initdb.d /docker-entrypoint-initdb.d

# Etapa 2: Construir a imagem do servidor web
FROM php:8.3-apache as ocomon_web

ENV OCOMON_LINK="https://sourceforge.net/projects/ocomonphp/files/OcoMon_5.0/Final/ocomon-5.0.tar.gz/download"
ENV FOLDER_NAME="ocomon-5.0"

# Instalar dependências PHP e outras ferramentas necessárias
RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    libonig-dev \
    libldap2-dev \
    libzip-dev \
    curl \
    cron \
    nano && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm && \
    docker-php-ext-install gd mysqli mbstring ldap zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configurar o timezone do PHP para o Brasil
RUN echo "date.timezone = America/Sao_Paulo" > /usr/local/etc/php/conf.d/timezone.ini

# Copiar o arquivo de configuração do Apache para permitir reescrita de URLs
COPY ./assets/000-default.conf /etc/apache2/sites-available/000-default.conf
# Habilitar o mod_rewrite do Apache
RUN a2enmod rewrite

# Copiar o arquivo de crontab
COPY ./assets/mycrontab /etc/cron.d/ocomon-cron
RUN chmod 0644 /etc/cron.d/ocomon-cron
# Apply cron job
RUN crontab /etc/cron.d/ocomon-cron
RUN touch /var/log/cron.log

# Baixar e configurar o Ocomon
RUN curl -L ${OCOMON_LINK} | tar -xz -C /var/www/html && \
    mv /var/www/html/${FOLDER_NAME}/* /var/www/html && \
    rm -Rf /var/www/html/${FOLDER_NAME} && \
    cp /var/www/html/includes/config.inc.php-dist /var/www/html/includes/config.inc.php && \
    chmod -R 755 /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Copiar o arquivo SQL de inicialização do banco de dados para o diretório apropriado
COPY --from=ocomon_web /var/www/html/install/5.x/01-DB_OCOMON_5.x-FRESH_INSTALL_STRUCTURE_AND_BASIC_DATA.sql /docker-entrypoint-initdb.d/init.sql

# Expor a porta 80 para o serviço web
EXPOSE 80

CMD ["apache2-foreground"]
