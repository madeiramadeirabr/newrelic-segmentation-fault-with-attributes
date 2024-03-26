#!/bin/bash

echo -e "Testing Segmentation Fault with the combination of PHP 8 Attributes and NewRelic PHP agent\n\n"
read -p "Use the version of NewRelic PHP agent with a bug (10.19.0.9) or the version without the bug (10.16.0.5)? (1 = '10.19.0.9' | 0 = '10.16.0.5') " NEWRELIC_VERSION

if [[ "$NEWRELIC_VERSION" == "1" ]]; then
    NEWRELIC_VERSION='10.19'
else
    NEWRELIC_VERSION='10.16'
fi

read -p "Test using PHP attributes? (1 = yes | 0 = no) " WITH_ATTRIBUTE

docker exec -it php-newrelic-test-agent-$NEWRELIC_VERSION /bin/sh -c "WITH_ATTRIBUTE_COMMAND=$WITH_ATTRIBUTE /application/console.php list && echo -e '\n\nfinished php script execution\n'"

printf "\nTail \"/var/log/newrelic/php_agent.log\":\n"
docker exec -it php-newrelic-test-agent-$NEWRELIC_VERSION tail /var/log/newrelic/php_agent.log
