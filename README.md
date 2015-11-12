# Ruby Passenger and Nginx tutorial

En este tutorial vamos a ver cómo hacer un deploy de una aplicación web
Ruby en producción utilizando [Nginx](http://nginx.org/) y [Phusion Passenger](https://www.phusionpassenger.com)
en una infraestructura sobre Debian GNU/Linux.

Los temas a tratar en este tutorial son:

1. Instalar el sistema base.
2. Instalar Nginx y Passenger.
3. Deployar una aplicación Rails.
4. Ab test y optimización.
5. Borrar el sistema base.

## Instalar el sistema base

Para comenzar se va a ejecutar un script que instala un sistema Debian Jessie en
un directorio local usando [chroot](https://en.wikipedia.org/wiki/Chroot) + [debootstrap](https://wiki.debian.org/Debootstrap);
además entre otras cosas instala Ruby, Sqlite3 y NodeJS.

```bash
git clone git@github.com:gramos/ruby-passenger-tutorial.git

cd ruby-passenger-tutorial

sudo ./bootstrap.sh
```

## Instalar Nginx y Passenger

Ahora vamos a agregar el repositorio de Phusion Passenger para poder
instalar la versión de Nginx con el módulo de Passenger incluido.
[Passenger Documentation](https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/ownserver/nginx/oss/jessie/install_passenger.html)

```bash
sudo chroot $(pwd)/tmp/jaulas/debian-jessie-passenger

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
apt-get install -y apt-transport-https ca-certificates

sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger jessie main > /etc/apt/sources.list.d/passenger.list'
apt-get update

apt-get install -y nginx-extras passenger
```
