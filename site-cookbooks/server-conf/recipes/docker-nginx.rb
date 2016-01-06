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
  notifies :redeploy, 'docker_container[nginx]'
end

docker_container 'nginx' do
  repo 'nginx'
  tag 'latest'
  port '80:80'
  host_name 'docker-nginx'
  domain_name 'surenot.ml'
  binds [ '/etc/nginx/conf.d/:/etc/nginx/conf.d' ]
  links ['transmission:transmission']
end
