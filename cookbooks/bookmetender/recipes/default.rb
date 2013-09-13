include_recipe "bookmetender::user"
user = data_bag_item('users', node['app']['user'])
app = node['name']

# passenger
include_recipe "passenger_apache2"

# DIR ~/apps/app
directory "#{user['home']}/apps/#{app}" do
  owner user['username']
  group user['group']
end

# add vhosts to apache
node['app']['vhosts'].each do |vhost|
  use_ssl = vhost['name'].include? 'ssl'
  error_log = "#{node['apache']['log_dir']}/#{vhost['name']}-error.log"
  access_log = "#{node['apache']['log_dir']}/#{vhost['name']}-access.log"
  
  # apache vhost conf
  web_app vhost['name'] do
    ssl use_ssl
    enable false
    cookbook 'bookmetender'
    server_name use_ssl ? "#{vhost['server_name']}:443" : "#{vhost['server_name']}"
    docroot "#{user['home']}/apps/#{app}/current/public"
    error_log_path error_log
    custom_log_path access_log
    rails_env node['app']['rails_env']
    customers_dir node['app']['customers_dir']
    if use_ssl
      ssl_certificate_file "#{node['ssl']['certificates_dir']}/#{node['ssl']['certificate_file']}"
      ssl_certificate_key_file "#{node['ssl']['certificates_dir']}/#{node['ssl']['certificate_key_file']}"
      ssl_certificate_chain_file "#{node['ssl']['certificates_dir']}/#{node['ssl']['certificate_chain_file']}"
    end
  end

  # logrotate for vhost
  logrotate_app vhost['name'] do
    cookbook "logrotate"
    path [error_log, access_log]
    frequency "daily"
    rotate 30
    create "644 root root"
  end
end

unless node['app']['db_user'].nil?
  # create app database in mysql and grant rights to user app db_user
  app_db_sql_path = "#{user['home']}/apps/#{app}/#{app}_db.sql"

  template app_db_sql_path do
    owner user['username']
    group user['group']
    mode '0600'
    source "#{app}_db.sql.erb"
  end

  execute "mysql-install-user-privileges" do
    command %Q["#{node['mysql']['mysql_bin']}" -u root #{node['mysql']['server_root_password'].empty? ? '' : '-p' }'#{node['mysql']['server_root_password']}' < "#{app_db_sql_path}"]
    action :nothing
    subscribes :run, resources("template[#{app_db_sql_path}]"), :immediately
  end

  execute "cleanup-after-mysql-install-user-privileges" do
    command "rm #{app_db_sql_path}"
    action :nothing
    subscribes :run, "execute[mysql-install-user-privileges]", :delayed
  end
end