ssl = data_bag_item('ssl', 'club')

certificates_dir = node['ssl']['certificates_dir'].to_s
certificate_file = node['ssl']['certificate_file'].to_s
key_file = node['ssl']['certificate_key_file'].to_s
chain_file = node['ssl']['certificate_chain_file'].to_s

# DIR certificates_dir
directory certificates_dir do
  owner 'root'
  group node['ssl']['group'].to_s
end

# crt file
crt_path = "#{File.join certificates_dir, certificate_file}"
file crt_path do
  owner 'root'
  group 'root'
  mode '0644'
  content ssl['certificate']
  not_if { File.exists? crt_path }
end

# key file
key_path = "#{File.join certificates_dir, key_file}"
file key_path do
  owner 'root'
  group 'root'
  mode '0600'
  content ssl['key']
  not_if { File.exists? key_path }
end

# chain file
chain_path = "#{File.join certificates_dir, chain_file}"
file chain_path do
  owner 'root'
  group node['ssl']['group'].to_s
  mode '0640'
  content ssl['chain']
  not_if { File.exists? chain_path }
end
