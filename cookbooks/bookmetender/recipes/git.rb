# prepare server for gitolite installation (this will be done manually)

# make sure needed packages are available
package "perl"
package "git-core"
package "ssh"

# create a user gitolite...
user 'gitolite' do
  group 'nogroup'
  home '/home/gitolite'
  shell '/bin/bash'
  supports manage_home: true
end

# ... and put my key there
me = data_bag_item('users', 'me')
unless me['ssh_key'].nil? || me['ssh_key'].empty?
  my_key_path = "/home/gitolite/#{me['name']}.pub"
  file my_key_path do
    owner 'gitolite'
    group 'nogroup'
    mode '0600'
    content me['ssh_key']
    not_if { File.exists? my_key_path }
  end
end
