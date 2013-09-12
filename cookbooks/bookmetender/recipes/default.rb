include_recipe "bookmetender::user"
user = data_bag_item('users', 'bmt')

# passenger
include_recipe "passenger_apache2"

# DIR ~/apps/club
directory "#{user['home']}/apps/club" do
  owner user['username']
  group user['group']
end

# install ssl certificate
include_recipe "bookmetender::ssl"

# add vhosts to apache
%w{ bmt-club bmt-club-ssl }.each do |app|
  use_ssl = app.include? 'ssl'
  error_log = "#{node['apache']['log_dir']}/#{app}-error.log"
  access_log = "#{node['apache']['log_dir']}/#{app}-access.log"
  
  # apache vhost conf
  web_app app do
    ssl use_ssl
    enable false
    cookbook 'bookmetender'
    server_name use_ssl ? 'club.bookmetender.com:443' : 'club.bookmetender.com'
    docroot "#{user['home']}/apps/club/current/public"
    error_log_path error_log
    custom_log_path access_log
    rails_env 'production'
    customers_dir 'system/customers'
    if use_ssl
      ssl_certificate_file "#{node['ssl']['certificates_dir']}/#{node['ssl']['certificate_file']}"
      ssl_certificate_key_file "#{node['ssl']['certificates_dir']}/#{node['ssl']['certificate_key_file']}"
      ssl_certificate_chain_file "#{node['ssl']['certificates_dir']}/#{node['ssl']['certificate_chain_file']}"
    end
  end

  # logrotate for app
  logrotate_app app do
    cookbook "logrotate"
    path [error_log, access_log]
    frequency "daily"
    rotate 30
    create "644 root root"
  end
end

# create app database in mysql and grant rights to user bmt
app_db_sql_path = "#{user['home']}/apps/club/club_db.sql"

template app_db_sql_path do
  owner user['username']
  group user['group']
  mode '0600'
  source 'app_db.sql.erb'
end

execute "mysql-install-user-privileges" do
  command %Q["#{node['mysql']['mysql_bin']}" -u root #{node['mysql']['server_root_password'].empty? ? '' : '-p' }'#{node['mysql']['server_root_password']}' < "#{app_db_sql_path}"]
  action :nothing
  subscribes :run, resources("template[#{app_db_sql_path}]"), :immediately
end
