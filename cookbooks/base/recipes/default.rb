package "git-core"
package "imagemagick"

# bundler
gem_package 'bundler' do
  if node[:bundler][:version]
    version node[:bundler][:version]
    action :install
  else
    action :install
  end
end
