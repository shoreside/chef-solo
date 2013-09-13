user = data_bag_item('users', node['app']['user'])

user user['username'] do
  group user['group']
  home user['home']
  shell user['shell']
  supports manage_home: true
end

# add ssh key to allow this user to deploy
unless user['ssh_key'].nil? || user['ssh_key'].empty?
  # DIR ~/.ssh
  directory "#{user['home']}/.ssh" do
    owner user['username']
    group user['group']
    mode '0700'
    recursive true
  end

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
