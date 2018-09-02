#!/bin/bash

set -e

SEMAPH=composer-running

# if it's not already there, install composer.
if ! [ -e /usr/local/bin/composer ]; then
    echo >&2 "first getting Composer"
    # Get Composer
    curl -S https://getcomposer.org/installer | php
    chmod a+x composer.phar
    mv composer.phar /usr/local/bin/composer
fi
if ! [ -e .git/hooks ]; then
    echo >&2 "creating a .git/hooks dir to avoid errors"
    mkdir -p .git/hooks
fi

if ! [ -f $SEMAPH ] ; then
    # create the semaphore file with the date in it...
    date > $SEMAPH


    # run composer to set up dependencies if not already there...
    if ! [ -e vendor/autoload.php ]; then
        echo >&2 "installing dependencies with Composer"
        composer install
    else
        echo >&2 "vendor dependencies already in place, updating."
        composer update
    fi

    #remove semaphore
    rm $SEMAPH
else
    echo >&2 "Looks like another composer is already running. If not, please remove $SEMAPH"
fi

exec "$@"
