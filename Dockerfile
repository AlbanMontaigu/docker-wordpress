# ================================================================================================================
#
# Wordpress with NGINX and PHP-FPM
#
# @see https://github.com/AlbanMontaigu/docker-nginx-php/blob/master/Dockerfile
# @see https://github.com/docker-library/wordpress/blob/master/fpm/Dockerfile
# ================================================================================================================

# Base is a nginx install with php
FROM amontaigu/nginx-php

# Maintainer
MAINTAINER alban.montaigu@gmail.com

# Wordpress env variables
ENV WORDPRESS_VERSION="4.2.2" WORDPRESS_UPSTREAM_VERSION="4.2.2" WORDPRESS_SHA1="d3a70d0f116e6afea5b850f793a81a97d2115039"

# install the PHP extensions we need
# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd \
    && docker-php-ext-install mysqli \
    && curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_UPSTREAM_VERSION}.tar.gz \
    && echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
    && tar -xzf wordpress.tar.gz -C /usr/src/ \
    && rm wordpress.tar.gz \
    && chown -R nginx:nginx /usr/src/wordpress

# Entrypoint to enable live customization
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Main folders tho share
VOLUME /var/www
WORKDIR /var/www

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord"]
