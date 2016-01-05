#
# Cookbook Name:: server-conf
# Recipe:: default
#
node.packages.each do |pkg|  
    package pkg
end

# provision sudo
include_recipe 'sudo'

# provision user account
include_recipe 'user::data_bag'

# provision ssh
include_recipe 'openssh'


# --------------------
# Transmission setup
# --------------------
directory '/etc/transmission-daemon' do
  recursive true
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file "/etc/transmission-daemon/settings.json" do
  source 'transmission/settings.json'
  owner 'root'
  group 'root'
  mode '0744'
end

docker_image 'dperson/transmission' do
  tag 'latest'
  action :pull
  notifies :redeploy, 'docker_container[docker-transmission]'
end

docker_container 'docker-transmission' do
  repo 'dperson/transmission'
  tag 'latest'
  port '9091:9091'
  host_name 'docker-transmission'
  domain_name 'transmission.surenot.ml'
  binds [ '/etc/transmission-daemon/:/var/lib/transmission-daemon/.config/transmission-daemon/' ]
end


# --------------------
# nginx setup
# --------------------
directory '/etc/nginx/conf.d' do
  recursive true
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file "/etc/nginx/conf.d/default.conf" do
  source 'nginx/default.conf'
  owner 'root'
  group 'root'
  mode '0744'
end

docker_image 'nginx' do
  tag 'latest'
  action :pull
  notifies :redeploy, 'docker_container[docker-nginx]'
end

docker_container 'docker-nginx' do
  repo 'nginx'
  tag 'latest'
  port '80:80'
  host_name 'docker-nginx'
  domain_name 'surenot.ml'
  binds [ '/etc/nginx/conf.d/:/etc/nginx/conf.d' ]
  links ['docker-transmission:transmission']
end
