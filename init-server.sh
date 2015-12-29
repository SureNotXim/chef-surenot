#Install chefdk and knife-solo on debian 8 x64
adduser surenot
su surenot

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable

#logout ctrl + D
su username
/bin/bash --login

#Not sure if version < 2 is needed
rvm list known
rvm install 1.9.3
rvm use 1.9.3
which ruby

#Need to install ruby > 2 for knife-solo...
rvm list known
rvm install 2.2

gem install knife-solo
gem install berkshelf

mkdir chef-kitchen
cd chef-kitchen
knife solo init .