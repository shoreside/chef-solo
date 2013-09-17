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
user_ssh_key_file = "#{user['home']}/.ssh/id_rsa"
execute "generate-ssh-skys-for-user" do
  creates "#{user_ssh_key_file}.pub"
  command "ssh-keygen -t rsa -q -f #{user_ssh_key_file} -P \"\" && chown #{user['username']} #{user_ssh_key_file}* && chgrp #{user['group']} #{user_ssh_key_file}*"
  subscribes :create, "user[user['username']]", :immediately
  not_if do
    File.exists?("#{user_ssh_key_file}.pub")
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

# add ssh key of the git server to user's known_hosts file
user_known_hosts = "#{user['home']}/.ssh/known_hosts"
execute "add-git-servers-ssh-key-to-users-known-hosts" do
  creates user_known_hosts
  command "ssh-keyscan -t rsa #{node['app']['git_server']} > #{user_known_hosts} && chown #{user['username']} #{user_known_hosts} && chgrp #{user['group']} #{user_known_hosts}"
  not_if do
    File.exists? user_known_hosts
  end
end
