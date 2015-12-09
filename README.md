# yii2 App Advanced Template run with vagrant
* This config add support vagrant for your web application(yii2 advanced template)
* And add support test environment at test.<you_suite>

## Out of the box...
* Ubuntu
* Nginx
* PHP-fpm ( +modules gd, imagick, pgsql, curl, mcrypt, xdebug)
* Postgres
* Redis

## Quick start...
### Install
* [Virtualbox](https://www.virtualbox.org/) + VirtualBox Extension Pack
* [Vagrant](http://www.vagrantup.com/)
* Install Vagrant plugins  
`vagrant plugin install vagrant-hostmanager vagrant-vbguest vagrant-cachier` 

### RUN
* Clone this sources from Git
* Copy files to project 
* It will start VM creation `vagrant up`
* After VM creat, run `chmod +x init && ./init --env=Development --overwrite=All && ./yii migrate/up`
 

### Description url
* fronted - <your_suite>/
* backend - <your_suite>/admin
* test frontend url - test.<your_suite>/
* test backend url - test.<your_suite>/admin
