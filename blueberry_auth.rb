load_template "http://github.com/jzajpt/rails-templates/raw/master/base.rb"

##
# Install plugin
plugin 'blueberry_auth',
  :git => 'git://github.com/jzajpt/blueberry_auth.git',
  :submodule => true

##
# Generate authenticated model and controller
if yes? 'Run generator? (yes/no)'
  generate "blueberry_auth"
end

git :add => '.'
git :commit => "-a -m 'Adding blueberry_auth.'"