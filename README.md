This [Docker Compose https://docs.docker.com/compose/] recipe creates a set of 3 Docker containers which should let you run a very efficient [Grav https://getgrav.org] website (or multiple sites).

It provides a container based on Debian Jessie running PHP 7.0 in FPM mode, with an Nginx container for serving it (you will need to have a reverse proxy to serve it and - I recommend - provide HTTPS support - I provide an example Nginx proxy configuration for this), and, for caching performance, an optional Redis container. Support for all of these is compiled into the PHP 7.0 container.

## Quick restart

To quickly get underway, you should be able to copy the sample docker-compose.yml-sample to docker-compose.yml
`cp docker-compose.yml-sample docker-compose.yml`
