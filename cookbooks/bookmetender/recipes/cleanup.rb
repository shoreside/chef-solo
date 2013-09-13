user = data_bag_item('users', node['app']['user'])
app = node['name']

app_db_sql_path = "#{user['home']}/apps/#{app}/#{app}_db.sql"
if File.exists?(app_db_sql_path)
  # remove generated mysql app database file
  file app_db_sql_path do
    action :delete
  end
end

if File.exists?(node['mysql']['grants_path'])
  # remove mysql root grants file
  file node['mysql']['grants_path'] do
    action :delete
  end
end
