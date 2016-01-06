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

# TODO dperson/transmission overwrites our mounted settings.json
# Follow github.com/dperson/transmission/issues/12
docker_container 'docker-transmission' do
  repo 'dperson/transmission'
  tag 'latest'
  port '9091:9091'
  host_name 'docker-transmission'
  domain_name 'transmission.surenot.ml'
  binds [ '/etc/transmission-daemon/:/var/lib/transmission-daemon/.config/transmission-daemon/' ]
end
