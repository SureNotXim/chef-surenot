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

file "/etc/transmission-daemon/settings.json" do
  # content nginx_conf
  content "{\n    \"alt-speed-down\": 50, \n    \"alt-speed-enabled\": false, \n    \"alt-speed-time-begin\": 540, \n    \"alt-speed-time-day\": 127, \n    \"alt-speed-time-enabled\": false, \n    \"alt-speed-time-end\": 1020, \n    \"alt-speed-up\": 50, \n    \"bind-address-ipv4\": \"0.0.0.0\", \n    \"bind-address-ipv6\": \"::\", \n    \"blocklist-enabled\": true, \n    \"blocklist-url\": \"http://www.example.com/blocklist\", \n    \"cache-size-mb\": 4, \n    \"dht-enabled\": true, \n    \"download-dir\": \"/var/lib/transmission-daemon/downloads\", \n    \"download-limit\": 100, \n    \"download-limit-enabled\": 0, \n    \"download-queue-enabled\": true, \n    \"download-queue-size\": 5, \n    \"encryption\": 1, \n    \"idle-seeding-limit\": 30, \n    \"idle-seeding-limit-enabled\": false, \n    \"incomplete-dir\": \"/var/lib/transmission-daemon/incomplete\", \n    \"incomplete-dir-enabled\": true, \n    \"lpd-enabled\": false, \n    \"max-peers-global\": 200, \n    \"message-level\": 1, \n    \"peer-congestion-algorithm\": \"\", \n    \"peer-id-ttl-hours\": 6, \n    \"peer-limit-global\": 200, \n    \"peer-limit-per-torrent\": 50, \n    \"peer-port\": 51413, \n    \"peer-port-random-high\": 65535, \n    \"peer-port-random-low\": 49152, \n    \"peer-port-random-on-start\": false, \n    \"peer-socket-tos\": \"lowcost\", \n    \"pex-enabled\": true, \n    \"port-forwarding-enabled\": false, \n    \"preallocation\": 1, \n    \"prefetch-enabled\": 1, \n    \"queue-stalled-enabled\": true, \n    \"queue-stalled-minutes\": 30, \n    \"ratio-limit\": 2, \n    \"ratio-limit-enabled\": true, \n    \"rename-partial-files\": true, \n    \"rpc-authentication-required\": true, \n    \"rpc-bind-address\": \"0.0.0.0\", \n    \"rpc-enabled\": true, \n    \"rpc-password\": \"transmission\", \n    \"rpc-port\": 9091, \n    \"rpc-url\": \"/transmission/\", \n    \"rpc-username\": \"transmission\", \n    \"rpc-whitelist\": \"*\", \n    \"rpc-whitelist-enabled\": true, \n    \"scrape-paused-torrents-enabled\": true, \n    \"script-torrent-done-enabled\": false, \n    \"script-torrent-done-filename\": \"\", \n    \"seed-queue-enabled\": false, \n    \"seed-queue-size\": 10, \n    \"speed-limit-down\": 100, \n    \"speed-limit-down-enabled\": false, \n    \"speed-limit-up\": 100, \n    \"speed-limit-up-enabled\": false, \n    \"start-added-torrents\": true, \n    \"trash-original-torrent-files\": false, \n    \"umask\": 18, \n    \"upload-limit\": 100, \n    \"upload-limit-enabled\": 0, \n    \"upload-slots-per-torrent\": 14, \n    \"utp-enabled\": true\n}"
  owner 'root'
  group 'root'
  mode '0755'
end

docker_image 'dperson/transmission' do
  tag 'latest'
  action :pull
  notifies :redeploy, 'docker_container[transmission-server]'
end

# Run Transmission container on port 9091
docker_container 'transmission-server' do
  repo 'dperson/transmission'
  tag 'latest'
  port '9091:9091'
  host_name 'ns334133.ip-178-32-220.eu'
  domain_name 'transmission.surenot.ml'
  binds [ '/etc/transmission-daemon/:/var/lib/transmission-daemon/.config/transmission-daemon/' ]
end


# --------------------
# nginx setup
# --------------------
# nginx_conf = data_bag_item('nginx-conf', default)['content']
directory '/etc/nginx/conf.d' do
  recursive true
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

file "/etc/nginx/conf.d/default.conf" do
  # content nginx_conf
  content "server {\n    listen       80;\n    server_name  transmission.surenot.ml;\n\n    location / {\n        proxy_pass http://transmission:9091;\n    }\n}\n\nserver {\n    listen       80;\n    server_name  localhost surenot.ml www.surenot.ml;\n\n    location / {\n        root   /usr/share/nginx/html;\n        index  index.html index.htm;\n    }\n}"
  owner 'root'
  group 'root'
  mode '0755'
end

# Pull latest image
docker_image 'nginx' do
  tag 'latest'
  action :pull
  notifies :redeploy, 'docker_container[my_nginx]'
end

# Run nginx container on port 80
docker_container 'my_nginx' do
  repo 'nginx'
  tag 'latest'
  port '80:80'
  host_name 'ns334133.ip-178-32-220.eu'
  domain_name 'surenot.ml'
  binds [ '/etc/nginx/conf.d/:/etc/nginx/conf.d' ]
  links ['transmission-server:transmission']
end
