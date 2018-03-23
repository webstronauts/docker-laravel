# docker-laravel

A Docker container we use as our default Laravel box. Please note that this box is used purely configured for _local development_ through [Laravel Liftoff](https://github.com/webstronauts/laravel-liftoff).

[![Docker Automated build](https://img.shields.io/docker/automated/webstronauts/laravel.svg)](https://hub.docker.com/r/webstronauts/laravel/)
[![Docker Build Status](https://img.shields.io/docker/build/webstronauts/laravel.svg)](https://hub.docker.com/r/webstronauts/laravel/builds/)

## Usage

### How to use this image

Create a `Dockerfile` in your Laravel project;

```dockerfile
FROM webstronauts/laravel:latest
```

You can then build and run the Docker image:

```console
$ docker build -t my-laravel-app .
$ docker run -it --rm --name my-laravel-app my-laravel-app
```

## License

MIT © [The Webstronauts](https://www.webstronauts.co)
