<div align="center">

# docker-laravel 🐳

An opiniated [Docker](https://www.docker.com/) container for [Laravel](https://laravel.com/) development.

<hr />

[![License](https://img.shields.io/github/license/webstronauts/docker-laravel.svg)](LICENSE.md)
[![Docker Automated build](https://img.shields.io/docker/automated/webstronauts/laravel.svg)](https://hub.docker.com/r/webstronauts/laravel/)
[![Docker Build Status](https://img.shields.io/docker/build/webstronauts/laravel.svg)](https://hub.docker.com/r/webstronauts/laravel/builds/)

</div>

Please note that this box is used purely configured for _local development_ through [Laravel Liftoff](https://github.com/webstronauts/laravel-liftoff) and assumes your application will be eventually deployed on [Heroku](https://github.com/heroku/heroku-buildpack-php).

## Usage

Create a `Dockerfile` in your Laravel Liftoff project;

```dockerfile
FROM webstronauts/laravel
```

You can then build and run the Docker image:

```console
$ docker build -t my-laravel-app .
$ docker run -it --rm --name my-laravel-app my-laravel-app
```

## Author(s)

Robin van der Vleuten ([@robinvdvleuten](https://twitter.com/robinvdvleuten)) - [The Webstronauts](https://www.webstronauts.co?utm_source=github&utm_medium=readme&utm_content=docker-laravel)
