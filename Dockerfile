FROM ten7/flightdeck-web-8.0

# Switch to root for the build.
USER root

# Copy the files needed by the site.
COPY init.yml /ansible/init.yml

# We need to reinvoke setcap to ensure HTTPD can run as non-root.
RUN setcap cap_net_bind_service=+ep /usr/sbin/httpd

# Switch back to apache for runtime.
USER apache

#
# Clone Drupal, get it ready for install.
#
# Here is where you would clone your site's repo and run your site's
# build processes such as composer and gulp. You do *not* bake in
# credentials here. That should be done in run.yml!
#
RUN composer create-project drupal/recommended-project:9.3.7 /tmp/drupal && \
    mv /tmp/drupal/composer* /var/www/ && \
    mv /tmp/drupal/vendor /var/www/ && \
    mv /tmp/drupal/web /var/www/ && \
    composer --working-dir=/var/www --no-cache require drush/drush && \
    composer --working-dir=/var/www --no-cache install && \
    mkdir -m 755 -p /var/www/files /var/www/config/sync /var/www/contrib-modules && \
    ln -sfn /var/www/files /var/www/web/sites/default/files && \
    ln -sfn /var/www/contrib-modules /var/www/web/modules/contrib && \
    cp /var/www/web/sites/default/default.settings.php /var/www/web/sites/default/settings.php && \
    chmod +w /var/www/web/sites/default/settings.php && \
    rm -rf /tmp/* /var/www/html

# Override the default Flight Deck docroot directory
ENV APACHE_DOCROOT_DIR /var/www/web

# Expose port 80
EXPOSE 80
