#
# Cookbook Name:: server-conf
# Recipe:: default
#
node.packages.each do |pkg|  
    package pkg
end

# provision user account
include_recipe 'user::data_bag'

# provision ssh
include_recipe 'openssh'
