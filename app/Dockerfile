
FROM php:7.4-apache

# Instalar extensiones necesarias
RUN docker-php-ext-install pdo pdo_mysql

RUN apt-get update && apt-get install -y apache2-utils
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

##RUN a2enmod rewrite

# Copiar el código de la aplicación
COPY . /var/www/html/

# Establecer el directorio de trabajo
WORKDIR /var/www/html/

EXPOSE 80

RUN chown -R www-data:www-data /var/www/html

# Configuración de salud (opcional)
HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost:80/ || exit 1