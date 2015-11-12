# Ruby Passenger and Ngnix tutorial

En este tutorial vamos a ver cómo hacer un deploy de una aplicación web
Ruby en producción utilizando [Ngnix](http://nginx.org/) y [Phusion Passenger](https://www.phusionpassenger.com)
en una infraestructura sobre Debian GNU/Linux.

Los temas a tratar en este tutorial son:
1. Instalar el sistema base.
2. Instalar Ngnix y Passenger.
3. Deployar una aplicación Rails.
4. Ab test y optimización.


## Instalar el sistema base

Para comenzar se va a ejecutar un script que instala un sistema Debian Jessie en
un directorio local usando [chroot](https://en.wikipedia.org/wiki/Chroot) + [debootstrap](https://wiki.debian.org/Debootstrap);
además entre otras cosas instala Ruby, Sqlite3 y NodeJS.

```
git clone git@github.com:gramos/ruby-passenger-tutorial.git

cd ruby-passenger-tutorial

sudo ./bootstrap.sh
```
