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

# nginx setup
#configuration on host
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
  content "server {\n    listen       80;\n    server_name  localhost;\n\n    #charset koi8-r;\n    #access_log  /var/log/nginx/log/host.access.log  main;\n\n    location / {\n        root   /usr/share/nginx/html;\n        index  index.html index.htm;\n    }\n\n    #error_page  404              /404.html;\n\n    # redirect server error pages to the static page /50x.html\n    #\n    error_page   500 502 503 504  /50x.html;\n    location = /50x.html {\n        root   /usr/share/nginx/html;\n    }\n\n    # proxy the PHP scripts to Apache listening on 127.0.0.1:80\n    #\n    #location ~ \\.php$ {\n    #    proxy_pass   http://127.0.0.1;\n    #}\n\n    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000\n    #\n    #location ~ \\.php$ {\n    #    root           html;\n    #    fastcgi_pass   127.0.0.1:9000;\n    #    fastcgi_index  index.php;\n    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;\n    #    include        fastcgi_params;\n    #}\n\n    # deny access to .htaccess files, if Apache's document root\n    # concurs with nginx's one\n    #\n    #location ~ /\\.ht {\n    #    deny  all;\n    #}\n}"
  owner 'root'
  group 'root'
  mode '0755'
end

file '/etc/nginx/conf.d/empty.conf' do
  content "#empty"
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

# Run container exposing ports
docker_container 'my_nginx' do
  repo 'nginx'
  tag 'latest'
  port '80:80'
  host_name 'ns334133.ip-178-32-220.eu'
  domain_name 'surenot.ml'
  binds [ '/etc/nginx/conf.d/:/etc/nginx/conf.d' ]
end
