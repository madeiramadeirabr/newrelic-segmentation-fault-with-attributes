# newrelic-segmentation-fault-with-attributes
Demo repository to reproduce the Segmentation Fault encountered when using NewRelic PHP Agent version 10.19.0.9 with [PHP attributes](https://www.php.net/manual/en/language.attributes.overview.php).

## How does the problem happen?
In an internal application we use the [AsCommand](https://symfony.com/doc/current/console.html#console_registering-the-command) attribute from the [symfony/console](https://packagist.org/packages/symfony/console) package to configure custom commands.

However, when updating NewRelic PHP Agent to version 10.19.0.9 we noticed that the application stopped working and no errors were reported in APM.

When analyzing the process logs we noticed that a Segmentation fault was occurring when trying to execute our script with custom commands of `symfony/console`.

Analyzing the `/var/log/newrelic/php_agent.log` file, we identified that the NewRelic PHP Agent reported that an error was occurring in the constructor of the `AsCommand` attribute:
```
Process 52 (version 10.19.0.9) received signal 11: segmentation violation
process id 52 fatal signal (SIGSEGV, SIGFPE, SIGILL, SIGBUS, ...)  - stack dump follows (code=0x7fc0f45f6000 bss=0x7fc0f47088bc):
No backtrace on this platform.
PHP execution trace follows...
#0 Symfony\Component\Console\Attribute\AsCommand->__construct() called at [/application/src/Command/AttributeCommand.php:12]
#1 unknown() called at [/application/src/Command/AttributeCommand.php:12]
#2 ReflectionAttribute->newInstance()
#3 Symfony\Component\Console\Command\Command->getDefaultName() called at [/application/vendor/symfony/console/Command/Command.php:100]
#4 Symfony\Component\Console\Command\Command->__construct() called at [/application/console.php:17]
#5 unknown() called at [/application/console.php:17]
```

## How to reproduce?
We prepared a docker image (`Dockerfile`) with a configuration close, but very simplified, to our application.

Using this image through Docker Compose, we create two containers:
 - One with the version of NewRelic PHP Agent that we identified the problem (`10.19.0.9`)
 - Another with the version we were using previously (`10.16.0.5`)

To make it easier to view the configuration of each container, we expose `phpinfo` through the built-in PHP web server on the following ports:
| Container | NewRelic PHP Agent Version | Port | Link to view PHP configuration |
| --------- | -------------------------- | ---- | ------------------------------ |
| php-newrelic-test-agent-10.19 | 10.19.0.9 | 8080 | http://localhost:8080/ |
| php-newrelic-test-agent-10.16 | 10.16.0.5 | 8081 | http://localhost:8081/ |


With this, we provide the `test.sh` script that enables the execution of the following test scenarios following of the tail of the `/var/log/newrelic/php_agent.log` file:
| Description | Container | With command using `AsCommand` attribute | Observed result |
| ----------- | --------- | ---------------------------------------- | --------------- |
| When using version `10.19.0.9` of NewRelic PHP Agent with at least one command using the `AsCommand` attribute, **a segmentation fault occurs** | php-newrelic-test-agent-10.19 | Yes | The list of application commands is not displayed because the `console.php` script is interrupted with the following message: "Segmentation fault (core dumped)". And there is an error trace in the `/var/log/newrelic/php_agent.log` file. |
| When using version `10.19.0.9` of the NewRelic PHP Agent without any command using the AsCommand attribute, no failure occurs. | php-newrelic-test-agent-10.19 | No | The application command list is displayed correctly with just one command. And no errors are written to the error in the `/var/log/newrelic/php_agent.log` file. |
| When using version `10.16.0.5` of NewRelic PHP Agent with at least one command using the `AsCommand` attribute, no failure occurs. | php-newrelic-test-agent-10.16 | Yes | The application command list is displayed correctly with two commands. And no errors are written to the error in the `/var/log/newrelic/php_agent.log` file. |
| When using version `10.16.0.5` of the NewRelic PHP Agent without any command using the AsCommand attribute, no failure occurs. | php-newrelic-test-agent-10.16 | No | The application command list is displayed correctly with just one command. And no errors are written to the error in the `/var/log/newrelic/php_agent.log` file. |
| 

## Running
After cloning the repository:

1. Copy the `.env.example` file to `.env` in the project root
1. Fill with your NewRelic key the environment `NEW_RELIC_LICENSE_KEY` in the `.env` file
1. Run containers with `docker compose up` (Docker BuildKit is required to build the image.)
1. Run the test script: `./test.sh`