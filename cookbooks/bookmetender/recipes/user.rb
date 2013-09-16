user = data_bag_item('users', node['app']['user'])

user user['username'] do
  group user['group']
  home user['home']
  shell user['shell']
  supports manage_home: true
end

# DIR ~/.ssh
directory "#{user['home']}/.ssh" do
  owner user['username']
  group user['group']
  mode '0700'
  recursive true
end

# generate user ssh keys
execute "generate-ssh-skys-for-user" do
  creates "#{user['home']}/.ssh/id_rsa.pub"
  command "ssh-keygen -t rsa -q -f #{user['home']}/.ssh/id_rsa -P \"\" && chown #{user['username']} #{user['home']}/.ssh/id_rsa* && chgrp #{user['group']} #{user['home']}/.ssh/id_rsa*"
  subscribes :create, "user[user['username']]", :immediately
  not_if do
    File.exists?("#{user['home']}/.ssh/id_rsa.pub")
  end
end

# add developers local machine ssh key to allow this user to deploy
unless user['ssh_key'].nil? || user['ssh_key'].empty?
  # FILE ~/.ssh/authorized_keys
  template "#{user['home']}/.ssh/authorized_keys" do
    owner user['username']
    group user['group']
    mode '0600'
    variables :ssh_key => user['ssh_key']
    source 'authorized_keys.erb'
  end
end

# DIR ~/apps
directory "#{user['home']}/apps" do
  owner user['username']
  group user['group']
end
