action :create do
  server_name = new_resource.server_name
  port = new_resource.port
  ssl = new_resource.ssl


  if ssl == true
    port = 443 if port.nil?
    vhostname = "/etc/nginx/vhosts/#{server_name}-ssl.conf"
  else
    port = 80 if port.nil?
    vhostname = "/etc/nginx/vhosts/#{server_name}.conf"
  end

  template vhostname do
    source "vhost.conf.erb"
    cookbook "passenger_nginx"
    variables({
      :server_name => server_name,
      :port => port,
      :ssl => ssl
    })
    notifies :reload, resources(:service => "nginx"), :delayed
  end

end
