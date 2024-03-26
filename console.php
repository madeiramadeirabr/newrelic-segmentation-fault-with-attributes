#!/usr/bin/env php
<?php

declare(strict_types=1);

use App\Command\AttributeCommand;
use App\Command\WithoutAttributeCommand;
use Symfony\Component\Console\Application;

require 'vendor/autoload.php';

$app = new Application();

$app->add(new WithoutAttributeCommand());

if (getenv('WITH_ATTRIBUTE_COMMAND') === '1') {
    $app->add(new AttributeCommand());
}

$app->run();
