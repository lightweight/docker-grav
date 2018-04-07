#!/bin/bash

set -e

# run composer to set up dependencies if not already there...
if ! [ -e vendor/autoload.php ]; then
    echo >&2 "installing dependencies with Composer"
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
    composer install
else
    echo >&2 "vendor dependencies already in place."
fi

exec "$@"
