action :create do
  template "/etc/nginx/vhosts/#{new_resource.server_name}.conf" do
    source "vhost.conf.erb"
    variables({
      :server_name => new_resource.server_name
    })
    notifies :reload, resources(:service => "nginx"), :immediately
  end
end
