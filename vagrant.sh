#!/usr/bin/env bash
# Options
packages=$(echo "$1")
github_token=$(echo "$2")
swapsize=$(echo "$3")
timezone=$(echo "$4")
sitename=$(echo "$5")
databasename=$(echo "$6")
databasepassword=$(echo "$7")

# Helpers
composer="hhvm /usr/local/bin/composer"

# System configuration
if ! grep --quiet "swapfile" /etc/fstab; then
  fallocate -l ${swapsize}M /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap defaults 0 0' >> /etc/fstab
fi

# Configuring timezone
echo "* * * * CONFIGURE TIMEZONE ${timezone} * * * *"
echo ${timezone} | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata

# Additional repositories
if [ ! -f /etc/apt/sources.list.d/hhvm.list ]; then
    sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
    sudo echo 'deb http://dl.hhvm.com/ubuntu trusty main' >> /etc/apt/sources.list.d/hhvm.list
fi

# Configuring server software
echo "* * * * MAKE DATABASE ${databasename} * * * *"
sudo su - postgres -c "echo \"ALTER ROLE postgres WITH password '${databasepassword}';\" | psql"
sudo su - postgres -c "createdb ${databasename} -E utf8 -T template0"

echo "* * * * SYSTEM UPDATE AND UPGRADE PACKAGES ${packages} * * * *"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y ${packages}

sudo php5enmod mcrypt

if ! grep --quiet '^xdebug.remote_enable = on$' /etc/php5/mods-available/xdebug.ini; then
    (
     echo "xdebug.remote_enable = on";
     echo "xdebug.remote_connect_back = on";
     echo "xdebug.remote_host = 10.0.2.2";
     echo "xdebug.idekey = \"vagrant\""
    ) >> /etc/php5/mods-available/xdebug.ini
fi

# install composer
echo "* * * * INSTALL COMPOSER * * * *"
if [ ! -f /usr/local/bin/composer ]; then
	sudo curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    ${composer} global require fxp/composer-asset-plugin --prefer-dist
else
	${composer} self-update
	${composer} global update --prefer-dist
fi
${composer} config --global github-oauth.github.com ${github_token}


# init application
echo "* * * * COMPOSER UPDATE OR INSTALL * * * *"
if [ ! -d /var/www/vendor ]; then
    cd /var/www && ${composer} install --prefer-dist --optimize-autoloader
else
    cd /var/www && ${composer} update --prefer-dist --optimize-autoloader
fi

# create nginx config
if [ ! -f /etc/nginx/sites-enabled/${sitename} ]; then
    echo "* * * * CONFIGURE SITE ${sitename}* * * *"
    sudo sed -e "s/\${site_name}/${sitename}/"  /var/www/vhost.conf.dist > /var/www/vhost.conf
    sudo ln -s /var/www/vhost.conf /etc/nginx/sites-enabled/${sitename}
fi

#php /var/www/console/yii app/setup --interactive=0
echo "* * * * RESTART SERVICES * * * *"
sudo service postgresql restart
sudo service php5-fpm restart
sudo service nginx restart
