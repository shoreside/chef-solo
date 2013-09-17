package "locales" do
  action :install
end

locale_and_encoding = "#{node[:locale][:lang]}.#{node[:locale][:encoding]}"
unless  ENV["LANGUAGE"] == locale_and_encoding &&
        ENV["LANG"] == locale_and_encoding &&
        ENV["LC_ALL"] == locale_and_encoding

  template "/etc/profile.d/lang.sh" do
    source "lang.sh.erb"
    mode "0644"
  end

  execute "locale-gen" do
    command "echo \"#{locale_and_encoding} #{node[:locale][:encoding]}\" > /etc/locale.gen && locale-gen"
  end

  execute "update-locale" do
    command "update-locale LANG=#{locale_and_encoding}"
    not_if "cat /etc/default/locale | grep -qx LANG=#{locale_and_encoding}"
  end
end

# these were set in /etc/locale.gen on the original machine
# de_DE ISO-8859-1
# de_DE.UTF-8 UTF-8
# de_DE@euro ISO-8859-15
