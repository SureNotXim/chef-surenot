# --------------------
# Transmission setup
# --------------------
directory '/var/local/transmission' do
  recursive true
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file "/var/local/transmission/settings.json" do
  source 'transmission/settings.json'
  owner 'root'
  group 'root'
  mode '0744'
end

docker_image 'surenot/transmission' do
  tag 'latest'
  action :pull
  notifies :redeploy, 'docker_container[transmission]'
end

docker_container 'transmission' do
  repo 'surenot/transmission'
  tag 'latest'
  port '9091:9091'
  host_name 'transmission'
  domain_name 'transmission.surenot.ml'
  binds [ '/var/local/transmission/:/var/lib/transmission-daemon/.config/transmission-daemon/' ]
end
