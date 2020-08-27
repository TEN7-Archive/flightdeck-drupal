FROM ten7/flight-deck-web:7.4

# Switch to root for the build.
USER root

# Copy the files needed by the site.
COPY run.yml /ansible/run.yml

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
RUN git clone --branch 8.9.x --depth 1 https://git.drupalcode.org/project/drupal.git /var/www/html && \
    rm -rf /var/www/html/.git && \
    composer --working-dir=/var/www/html install && \
    mkdir -m 755 -p /var/www/files /var/www/config/sync && \
    ln -sfn /var/www/files /var/www/html/sites/default/files && \
    cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php && \
    chmod +w /var/www/html/sites/default/settings.php

# Expose port 80, 443
EXPOSE 80 443
