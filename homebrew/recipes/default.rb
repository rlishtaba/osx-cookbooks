include_recipe "xcode"

execute node[:homebrew][:prefix] do
  command "sudo mkdir #{node[:homebrew][:prefix]}; " +
    "sudo chown #{node[:homebrew][:user]}:staff #{node[:homebrew][:prefix]}"
  creates node[:homebrew][:prefix]
end

directory "#{node[:homebrew][:prefix]}/bin" do
  action :create
  owner node[:homebrew][:user]
  group "staff"
end

homebrew_tar = "#{Chef::Config[:file_cache_path]}/mxcl-homebrew.tar.gz"

unless File.exist?("#{node[:homebrew][:prefix]}/bin/brew")
  remote_file homebrew_tar do
    source "http://github.com/mxcl/homebrew/tarball/master"
    owner node[:homebrew][:user]
    group "staff"
    action :create_if_missing
  end

  execute "tar -xzf #{homebrew_tar} -C #{node[:homebrew][:prefix]} --strip 1" do
    user node[:homebrew][:user]
    creates "#{node[:homebrew][:prefix]}/bin/brew"
  end

  file homebrew_tar do
    action :delete
  end
end

execute "brew cleanup" do
  command "#{node[:homebrew][:prefix]}/bin/brew cleanup"
  user node[:homebrew][:user]
  action :nothing
end

package "brew-gem"
package "brew-pip"

node[:homebrew][:formulas].each do |formula|
  package formula
end
