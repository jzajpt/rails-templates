load_template "http://github.com/jzajpt/rails-templates/raw/master/base.rb"

##
# Install plugin
plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', :submodule => true

##
# Generate authenticated model and controller
generate "authenticated", "user session"

##
# Convert authenticated views to HAML. Unfortunately html2haml generator is kinda broken
# and generated views needs to be fixed, so don't forget to fix them.
inside('app/views/') do
  run "html2haml sessions/new.html.erb sessions/new.html.haml"
  run "rm sessions/new.html.erb"
  run "html2haml users/new.html.erb users/new.html.haml"
  run "rm users/new.html.erb"
  run "html2haml users/_user_bar.html.erb users/_user_bar.html.haml"
  run "rm users/_user_bar.html.erb"
end

git :add => '.'
git :commit => "-a -m 'Adding restful-authentication.'"