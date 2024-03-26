<?php

declare(strict_types=1);

namespace App\Command;

use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'test:attribute-command',
    description: 'An example command that uses the "AsCommand" attribute'
)]
final class AttributeCommand extends Command
{
    /**
     * @inheritdoc
     */
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $output->writeln('Hello World! I am a Command register with "AsCommand" Symfony Attribute');
    }
}
