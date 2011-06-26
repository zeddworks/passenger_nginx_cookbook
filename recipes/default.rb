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
  not_if "test -f /usr/sbin/nginx"
end

execute "extract-nginx" do
  command "tar zxvf nginx-#{nginx_version}.tar.gz"
  cwd "/tmp"
  not_if "test -f /usr/sbin/nginx"
end

gem_package "passenger"

execute "compile-nginx" do
  command "passenger-install-nginx-module --auto --prefix=/usr --nginx-source-dir=/tmp/nginx-#{nginx_version} --extra-configure-flags='--conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock'"
  not_if "test -f /usr/sbin/nginx"
end

cookbook_file "/etc/init.d/nginx" do
  source "nginx-common.init.d"
  mode "0755"
  action :create_if_missing
end

service "nginx" do
  supports :restart => true, :reload => true, :status => true
  action [ :enable, :start ]
end
