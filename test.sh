#!/bin/sh

echo "Testing Segmentation Fault with the combination of PHP 8 Attributes and NewRelic PHP agent version 10.19.0.9\n\n"
read -p "Test using PHP attributes? (1 = yes | 0 = no) " WITH_ATTRIBUTE

docker exec -it php-newrelic-test /bin/sh -c "WITH_ATTRIBUTE_COMMAND=$WITH_ATTRIBUTE /application/console.php list && echo -e '\n\nfinished php script execution\n'"

printf "\nTail \"/var/log/newrelic/php_agent.log\":\n"
docker exec -it php-newrelic-test tail /var/log/newrelic/php_agent.log