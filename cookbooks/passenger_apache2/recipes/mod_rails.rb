#
# Cookbook Name:: passenger_apache2
# Recipe:: mod_rails
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Joshua Sierles (<joshua@37signals.com>)
# Author:: Michael Hale (<mikehale@gmail.com>)
#
# Copyright:: 2009, Opscode, Inc
# Copyright:: 2009, 37signals
# Coprighty:: 2009, Michael Hale
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'passenger_apache2'

if platform_family?('debian')
  node.default['passenger']['root_path'] = "#{node['languages']['ruby']['gems_dir']}/gems/passenger-#{node['passenger']['version']}"
  node.default['passenger']['module_path'] = "#{node['passenger']['root_path']}/buildout/apache2/mod_passenger.so"

  template "#{node['apache']['dir']}/mods-available/mod_rails.load" do
    cookbook 'passenger_apache2'
    source 'mod_rails.load.erb'
    owner 'root'
    group 'root'
    mode 0644
  end

  template "#{node['apache']['dir']}/mods-available/mod_rails.conf" do
    cookbook 'passenger_apache2'
    source 'mod_rails.conf.erb'
    owner 'root'
    group 'root'
    mode 0644
  end
end

apache_module 'mod_rails' do
  module_path node['passenger']['module_path']
end
