#
# Cookbook Name:: passenger_nginx
# Recipe:: default
#
# Copyright 2011, ZeddWorks
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

nginx_version="1.0.4"

remote_file "/tmp/nginx-#{nginx_version}.tar.gz" do
  source "http://nginx.org/download/nginx-#{nginx_version}.tar.gz"
  action :create_if_missing
  not_if "test -f /opt/nginx/sbin/nginx"
end

execute "extract-nginx" do
  command "tar zxvf nginx-#{nginx_version}.tar.gz"
  cwd "/tmp"
  not_if "test -d /tmp/nginx-#{nginx_version}"
  only_if "test -f /tmp/nginx-#{nginx_version}.tar.gz"
end

gem_package "passenger"

execute "compile-nginx" do
  command "passenger-install-nginx-module --auto --prefix=/opt/nginx --nginx-source-dir=/tmp/nginx-#{nginx_version} --extra-configure-flags='--conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock'"
  not_if "test -f /opt/nginx/sbin/nginx"
end

if platform? ("ubuntu", "debian")
  cookbook_file "/etc/init.d/nginx" do
    source "nginx-common.init.d"
    mode "0755"
    action :create_if_missing
  end
end

if platform? "redhat"
  cookbook_file "/etc/init.d/nginx" do
    source "RedHatNginxInitScript"
    mode "0755"
    action :create_if_missing
  end
end

user "nginx" do
  home "/srv/rails"
  comment "nginx"
  system true
  shell "/bin/bash"
end

case node['platform']
when "redhat"
  ohai "reload_users_groups"
end

group "nginx" do
  members ['nginx']
end

directory "/srv/rails" do
  owner "nginx"
  group "nginx"
  mode "0755"
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  notifies :restart, "service[nginx]"
end

directory "/etc/nginx/vhosts"

service "nginx" do
  supports :restart => true, :reload => true, :status => true
  action [ :enable, :start ]
end
