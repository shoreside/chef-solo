package "git-core"
package "imagemagick"

# bundler
gem_package 'bundler' do
  if node[:bundler] && node[:bundler][:version]
    version node[:bundler][:version]
    action :install
  else
    action :install
  end
end

# remove unused package
package "isc-dhcp-client" do
  action :purge
end

# add some Intrusion Prevention System
package "fail2ban"