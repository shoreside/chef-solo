# remove mysql root grants file
execute "cleanup-after-mysql-install-privileges" do
  command "rm #{node['mysql']['grants_path']}"
  action :nothing
  subscribes :run, "execute[mysql-install-privileges]", :delayed
end
