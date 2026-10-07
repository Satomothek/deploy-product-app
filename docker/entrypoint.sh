#!/bin/sh
set -e

# Hosting biasanya memberi port lewat variabel PORT
PORT="${PORT:-80}"
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

php artisan config:cache
php artisan migrate --force

if [ "$RUN_SEED" = "true" ]; then
    php artisan db:seed --force
fi

exec apache2-foreground
