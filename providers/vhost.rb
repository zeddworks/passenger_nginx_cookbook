action :create do
  template "/etc/nginx/vhosts/#{new_resource.server_name}.conf" do
    source "vhost.conf.erb"
    variables({
      :server_name => new_resource.server_name
    })
    notifies :restart, "service[nginx]"
  end
  service "nginx" do
      supports :restart => true, :reload => true, :status => true
        action [ :enable, :start ]
  end
end
