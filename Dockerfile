# ================================================================================================================
#
# Wordpress with NGINX and PHP-FPM
#
# @see https://github.com/AlbanMontaigu/docker-nginx-php/blob/master/Dockerfile
# @see https://github.com/docker-library/wordpress/blob/master/fpm/Dockerfile
# @see https://wordpress.org/download/release-archive/
# ================================================================================================================

# Base is a nginx install with php
FROM amontaigu/nginx-php:5.6.29

# Maintainer
MAINTAINER alban.montaigu@gmail.com

# Wordpress env variables
ENV WORDPRESS_VERSION="4.7" \
    WORDPRESS_SHA1="1e14144c4db71421dc4ed22f94c3914dfc3b7020"

# System update & install the PHP extensions we need
RUN apt-get update \
    && apt-get install -y libpng12-dev libjpeg-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd mysqli bcmath

# Getting Wordpress and install it
# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
    && echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
    && tar -xzf wordpress.tar.gz -C /usr/src/ \
    && rm wordpress.tar.gz \
    && chown -Rfv nginx:nginx /usr/src/wordpress

# NGINX tuning for WORDPRESS
COPY ./nginx/conf/sites-enabled/default.conf /etc/nginx/sites-enabled/default.conf

# Entrypoint to enable live customization
COPY docker-entrypoint.sh /docker-entrypoint.sh

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord"]
