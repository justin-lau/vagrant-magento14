#!/usr/bin/env bash

# https://gist.github.com/epiloque/8cf512c6d64641bde388
parse_yaml() {
    local prefix=$2
    local s
    local w
    local fs
    s='[[:space:]]*'
    w='[a-zA-Z0-9_]*'
    fs="$(echo @|tr @ '\034')"
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
    awk -F"$fs" '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, $3);
        }
    }' | sed 's/_=/+=/g'
}

eval $(parse_yaml /vagrant/config.yml 'settings_')

# disable mysql root password prompt
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y apache2 mysql-server libapache2-mod-auth-mysql php5-mysql php5 libapache2-mod-php5 php5-mcrypt php5-gd php5-curl php5-cli

/usr/bin/mysqladmin -u root password $settings_mysql_root_password
sudo mysql_install_db

echo "Creating database `$settings_mysql_database`..."
mysql -uroot -p$settings_mysql_root_password -e "CREATE DATABASE IF NOT EXISTS $settings_mysql_database;"
echo "Creating database user `$settings_mysql_username`..."
mysql -uroot -p$settings_mysql_root_password -e "CREATE USER '$settings_mysql_username'@'localhost' IDENTIFIED BY '$settings_mysql_password';"
echo "Granting database user `$settings_mysql_username` the privileges..."
mysql -uroot -p$settings_mysql_root_password -e "GRANT ALL ON $settings_mysql_database.* TO '$settings_mysql_username'@'localhost';"
echo "Importing database from file..."
zcat /vagrant_data/$settings_mysql_import_from_file | mysql -uroot -p$settings_mysql_root_password $settings_mysql_database

sudo a2enmod rewrite
sudo service apache2 restart
