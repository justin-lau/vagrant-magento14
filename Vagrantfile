# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

settings = YAML.load_file 'config.yml'

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/precise64"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.synced_folder settings['apache2']['www_path'], '/var/www'
  config.vm.synced_folder settings['mysql']['import_from_dir'], '/vagrant_data' if settings['mysql']['import_from_dir'] and settings['mysql']['import_from_file']
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
  end
  
  config.vm.provision :shell, path: "bootstrap.sh"
end
