<?php

/*
 * This file is part of the Doctum utility.
 *
 * (c) Fabien Potencier <fabien@symfony.com>
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */

namespace Doctum\Console\Command;

use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class ParseCommand extends Command
{
    /**
     * @see Command
     */
    protected function configure()
    {
        parent::configure();

        $this->addForceOption();
        $this->addIgnoreParseErrors();

        $this
            ->setName('parse')
            ->setDescription('Parses a project')
            ->setHelp(
                <<<EOF
The <info>%command.name%</info> command parses a project and generates a database
with API information:

    <info>php %command.full_name% config/symfony.php</info>

The <comment>--force</comment> option forces a rebuild (it disables the
incremental parsing algorithm):

    <info>php %command.full_name% config/symfony.php --force</info>

The <comment>--version</comment> option overrides the version specified
in the configuration:

    <info>php %command.full_name% config/symfony.php --version=main</info>
EOF
            );
    }

    /**
     * @see Command
     *
     * @throws \InvalidArgumentException When the target directory does not exist
     */
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $output->writeln('<bg=cyan;fg=white> Parsing project </>');

        return $this->parse($this->doctum['project']);
    }
}
