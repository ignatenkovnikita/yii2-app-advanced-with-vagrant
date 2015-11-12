# yii2 App Advanced Template run with vagrant

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

