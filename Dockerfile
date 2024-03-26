# syntax=docker/dockerfile:1
FROM php:8-cli-alpine3.13

ARG NEW_RELIC_LICENSE_KEY
ARG NEW_RELIC_APP_NAME=ExampleApp

# Prepare required directories for Newrelic installation
RUN mkdir -p /var/log/newrelic /var/run/newrelic && \
    touch /var/log/newrelic/php_agent.log /var/log/newrelic/newrelic-daemon.log && \
    chmod -R g+ws /tmp /var/log/newrelic/ /var/run/newrelic/ && \
    chown -R 1001:0 /tmp /var/log/newrelic/ /var/run/newrelic/ && \
    # Download and install Newrelic binary
    export NEWRELIC_VERSION="10.19.0.9" && \
    export NEWRELIC_VERSION_NAME="newrelic-php5-${NEWRELIC_VERSION}-linux-musl" && \
    cd /tmp && curl -sS "https://download.newrelic.com/php_agent/archive/${NEWRELIC_VERSION}/${NEWRELIC_VERSION_NAME}.tar.gz" | gzip -dc | tar xf - && \
    cd "${NEWRELIC_VERSION_NAME}" && \
    NR_INSTALL_USE_CP_NOT_LN=true NR_INSTALL_SILENT=true ./newrelic-install install && \
    rm -f /var/run/newrelic-daemon.pid && \
    # Configure Newrelic APM
    # To simplify the example, we pass the license (secret value) as build arg.
    sed -i \
        -e "s/newrelic.license =.*/newrelic.license = $NEW_RELIC_LICENSE_KEY/" \
        -e "s/newrelic.appname =.*/newrelic.appname = $NEW_RELIC_APP_NAME/" \
        -e "s/;newrelic.distributed_tracing_enabled =.*/newrelic.distributed_tracing_enabled = true/" \
        -e "s/;newrelic.loglevel =.*/newrelic.loglevel = verbosedebug/" \
        -e "s/;newrelic.daemon.loglevel =.*/newrelic.daemon.loglevel = debug/" \
        -e "s#newrelic.logfile =.*#newrelic.logfile = /var/log/newrelic/php_agent.log#" \
        -e "s#newrelic.daemon.logfile =.*#newrelic.daemon.logfile = /var/log/newrelic/newrelic-daemon.log#" \
        $PHP_INI_DIR/conf.d/newrelic.ini \
    && rm -rf /tmp/* /var/cache/*

RUN ln -s "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

WORKDIR /application

ADD --checksum=sha256:049b8e0ed9f264d770a0510858cffbc35401510759edc9a784b3a5c6e020bcac --chmod=755  https://getcomposer.org/download/2.7.2/composer.phar /usr/local/bin/

# We use the built-in web server just to make it easier to view the PHP configuration
CMD composer.phar install \
    && php -S 0.0.0.0:8080 -t public/