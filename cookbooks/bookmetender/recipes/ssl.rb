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
file "#{File.join certificates_dir, certificate_file}" do
  owner 'root'
  group 'root'
  mode '0644'
  content ssl['certificate']
end

# key file
file "#{File.join certificates_dir, key_file}" do
  owner 'root'
  group 'root'
  mode '0600'
  content ssl['key']
end

# chain file
file "#{File.join certificates_dir, chain_file}" do
  owner 'root'
  group node['ssl']['group'].to_s
  mode '0640'
  content ssl['chain']
end
