load_template "http://github.com/jzajpt/rails-templates/raw/master/base.rb"

##
# Install plugin
plugin 'restful-authentication',
  :git => 'git://github.com/technoweenie/restful-authentication.git',
  :submodule => true

##
# Generate authenticated model and controller
if yes? 'Generate authenticated (user model, sessions controller)?'
  generate "authenticated", "user session"
end

git :add => '.'
git :commit => "-a -m 'Adding restful-authentication.'"