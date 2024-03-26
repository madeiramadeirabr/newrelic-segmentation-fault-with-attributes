<?php

declare(strict_types=1);

namespace App\Command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

final class WithoutAttributeCommand extends Command
{
    /**
     * @var string|null The default command name
     */
    protected static $defaultName = 'test:without-attribute-command';

    /**
     * @inheritdoc
     */
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $output->writeln('Hello World! I am a Command register without "AsCommand" Symfony Attribute');
    }
}
