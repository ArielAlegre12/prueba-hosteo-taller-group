FROM php:8.4-apache

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip git curl sqlite3 libsqlite3-dev \
    && docker-php-ext-install pdo pdo_sqlite

# Habilitar rewrite
RUN a2enmod rewrite

# Copiar proyecto
COPY . /var/www/html

# Apache apuntando correctamente a /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# Instalar Composer + dependencias
RUN curl -sS https://getcomposer.org/installer | php \
    && php composer.phar install --no-dev --optimize-autoloader

# 🔥 Crear base de datos SQLite (IMPORTANTE)
RUN mkdir -p /var/www/html/database && \
    touch /var/www/html/database/database.sqlite

# 🔥 Limpiar y cachear config
RUN php artisan config:clear && \
    php artisan config:cache

# Permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database

EXPOSE 80

CMD ["apache2-foreground"]