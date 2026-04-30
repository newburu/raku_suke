desc "Debug puma service file"
task :debug_puma do
  require 'capistrano/puma/systemd'
  template_puma('puma', 'puma.service', 'systemd') rescue puts "Failed"
end
