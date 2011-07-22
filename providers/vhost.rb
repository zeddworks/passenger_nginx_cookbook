action :create do
  server_name = new_resource.server_name
  listen_string = new_resource.listen_string
  if listen_string.nil?
    listen_string = "80"
  end
  template "/etc/nginx/vhosts/#{server_name}.conf" do
    source "vhost.conf.erb"
    cookbook "passenger_nginx"
    variables({
      :server_name => server_name,
      :listen_string => listen_string
    })
    notifies :reload, resources(:service => "nginx"), :delayed
  end
end
