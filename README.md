# Ruby Passenger and Nginx tutorial

En este tutorial vamos a ver cómo hacer un deploy de una aplicación web
Ruby en producción utilizando [Nginx](http://nginx.org/) y [Phusion Passenger](https://www.phusionpassenger.com)
en una infraestructura sobre Debian GNU/Linux.

Los temas a tratar en este tutorial son:

1. Instalar el sistema base.
2. Instalar Nginx y Passenger.
3. Deployar una aplicación Rails.
4. Benchmarking tool y optimización.
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
Los pasos a seguir son que estan descriptos en la documentacion de passenger
[Passenger Documentation](https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/ownserver/nginx/oss/jessie/install_passenger.html)

```bash
sudo chroot $(pwd)/tmp/jaulas/debian-jessie-passenger

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
apt-get install -y apt-transport-https ca-certificates

sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger jessie main > /etc/apt/sources.list.d/passenger.list'
apt-get update

apt-get install -y nginx-extras passenger
```

## Deployar una app Rails.

Vamos a clonar una app rails de ejemplo desde el repo de phusion.

```bash
cd /var/www
git clone https://github.com/phusion/passenger-ruby-rails-demo.git
cd passenger-ruby-rails-demo
bundle install --deployment --without development test
```

Ahora tenemos que crear la secret key:

```bash
bundle exec rake secret
```

Editar config/secrets.yml y poner la clave generada:

```
production:
  secret_key_base: the value that you copied from 'rake secret'
```

Ademas tenemos que poner los permisos correctos en algunos archivos de configuracion:

```
chmod 700 config db
chmod 600 config/database.yml config/secrets.yml
```

Luego precompilamos los assets y corremos las migraciones:
q
```
bundle exec rake assets:precompile db:migrate RAILS_ENV=production
```

```
cd ..
chown www-data:www-data passenger-ruby-rails-demo -R
```

Necesitamos habilitar passenger en el archivo de configuracion de nginx, editamos
/etc/nginx/nginx.conf y hacemos lo siguiente:

agregamos esto en la primer linea, para que nginx pueda encontrar nodejs sin problemas:

```
env PATH ;
```

luego descomentamos las dos siguientes líneas:

```
  # passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
  # passenger_ruby /usr/bin/passenger_free_ruby;
```

Ahora vamos a agregar la configuracion necesaria para que nginx levante la app,
vamos a crear un archivo en /etc/nginx/sites-available/passenger-ruby-rails-demo

```
server {
    server_name passenger-ruby-rails-demo.com;
    root /var/www/passenger-ruby-rails-demo/public;
    passenger_ruby /usr/bin/ruby;
    passenger_enabled on;
    passenger_sticky_sessions on;
}

```
Ademas necesitamos crear un symlink para habilitar el nuevo virtual host:

```
ln -s /etc/nginx/sites-available/passenger-ruby-rails-demo /etc/nginx/sites-enabled/passenger-ruby-rails-demo
```

Editamos el archivo /etc/hosts y agregamos la siguiente línea para configurar el host virtual:

```
127.0.0.1       passenger-ruby-rails-demo.com
```

Finalmente reiniciamos el servicio de nginx

```
service nginx reload
```

Para comprobar que todo haya funcionado, hacemos uso del comando curl y nos devuelve la app de rails

```
curl passenger-ruby-rails-demo.com
```

## Benchmarking y optimización.

https://www.phusionpassenger.com/library/config/nginx/optimization/

Vamos a usar la herramienta recomendada por Phusion Passenger llamada **wrk**,
hay que instalar la lib de ssl requerida para compilarlo para compilarlo:


```
apt-get install libssl-dev
```

después clonamos el repo y compilamos

```
git clone https://github.com/wg/wrk.git /opt/wrk
cd /opt/wrk
make
```

Despues ejecutamos wrk de la siguiente manera:

```
root@noesmia:/opt/wrk# ./wrk -t12 -c100 -d30s http://passenger-ruby-rails-demo.com
Running 30s test @ http://passenger-ruby-rails-demo.com
12 threads and 100 connections
Thread Stats   Avg      Stdev     Max   +/- Stdev
Latency   118.45ms    6.57ms 163.60ms   86.06%
Req/Sec    67.44     10.28    80.00     63.46%
24279 requests in 30.06s, 36.01MB read
Requests/sec:    807.74
Transfer/sec:      1.20MB
```

El comando corre un benchmark por 30 segundos, usando 12 threads y
mantiene 100 conexiones HTTP abiertas.

Despues de unos segundos de correr wrk, corremos passenger-status:

```
root@noesmia:/# passenger-status
Version : 5.0.21
Date    : 2015-11-17 16:37:57 +0000
Instance: Ran06atn (nginx/1.8.0 Phusion_Passenger/5.0.21)

----------- General information -----------
Max pool size : 6
App groups    : 1
Processes     : 6
Requests in top-level queue : 0

----------- Application groups -----------
/var/www/passenger-ruby-rails-demo/public:
App root: /var/www/passenger-ruby-rails-demo
Requests in queue: 0
* PID: 9675    Sessions: 0       Processed: 26557   Uptime: 12m 1s
CPU: 14%     Memory  : 39M     Last used: 0s ago
* PID: 9682    Sessions: 0       Processed: 26709   Uptime: 12m 1s
CPU: 14%     Memory  : 36M     Last used: 0s ago
* PID: 9689    Sessions: 0       Processed: 26705   Uptime: 12m 1s
CPU: 14%     Memory  : 36M     Last used: 0s ago
* PID: 9694    Sessions: 0       Processed: 26646   Uptime: 12m 0s
CPU: 14%     Memory  : 36M     Last used: 0s ago
* PID: 9703    Sessions: 0       Processed: 26706   Uptime: 12m 0s
CPU: 14%     Memory  : 36M     Last used: 0s ago
* PID: 9710    Sessions: 0       Processed: 26814   Uptime: 12m 0s
CPU: 14%     Memory  : 36M     Last used: 0s ago
```

Con esta informacion podemos hacer algunos calculos para optimizar
un poco passenger y aumentar la cantidad de procesos. Tenemos que usar
la formula descripta en la doc de passenger.

max_app_processes = (TOTAL_RAM * 0.75) / RAM_PER_PROCESS

( 8000 * 0.75 ) / 50 = 120 max_app_processes
