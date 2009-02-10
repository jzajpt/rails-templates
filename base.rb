#
# Delete unnecessary files
run "rm README"
run "rm public/index.html"
run "rm -f public/javascripts/*"

##
# Download JQuery
run "curl -s -L http://jqueryjs.googlecode.com/files/jquery-1.3.1.min.js > public/javascripts/jquery.js"

##
# Create gitignore files
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END

##
# Initialize git repository
git :init


##
# Install plugins
plugin 'i18n_label',             :git => 'git://github.com/iain/i18n_label.git', :submodule => true
plugin 'blueberry_scaffold',     :git => 'git://github.com/jzajpt/blueberry_scaffold.git', :submodule => true

##
# Setup gems requirements
gem "thoughtbot-shoulda",      :lib => "shoulda", :source => "http://gems.github.com"
gem 'thoughtbot-factory_girl', :lib => 'factory_girl',  :source => 'http://gems.github.com'
gem 'rubyist-aasm',            :lib => 'aasm', :source => 'http://gems.github.com'
gem 'mislav-will_paginate',    :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'mocha'
gem 'haml'

##
# Create locale initializer
initializer 'locale.rb', "I18n.default_locale = 'cs'"

##
# Fetch Czech locales
inside('config/locales') do
  run "curl -s -L http://gist.github.com/60344.txt > cs_active_record.yml"
  run "curl -s -L http://gist.github.com/60343.txt > cs_active_support.yml"
  run "curl -s -L http://gist.github.com/60342.txt > cs_action_view.yml"
end

if yes?('Use restful-authentication plugin? (y/N)')
  ##
  # Install plugin
  plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', :submodule => true

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
  
  ##
  # Generate authenticated model and controller
  generate "authenticated", "user session"
end

##
# Fetch LabeledFormBuilder
inside('app') do
  run "mkdir form_builders"
end
run 'curl -s -L http://gist.github.com/60353.txt > app/form_builders/labeled_form_builder.rb'

gsub_file 'config/environment.rb',
  '# config.load_paths += %W( #{RAILS_ROOT}/extras )', 'config.load_paths += %W( #{RAILS_ROOT}/app/form_builders )'

file 'app/helpers/application_helper.rb', 
%Q{# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def labeled_form_for(*args, &block)
    options = args.extract_options!.merge(:builder => LabeledFormBuilder)
    form_for(*(args + [options]), &block)
  end
end}

##
# Create application HAML layout
file 'app/views/layouts/application.html.haml', 
%Q{!!! Strict
%html{ html_attrs("cz_CZ") }
  %head
    %meta{ :content => 'text/html; charset=utf-8', 'http-equiv' => 'content-type' }/
    %title Application Template
    = javascript_include_tag 'jquery', 'application'
    = stylesheet_link_tag 'application', :media => 'all'
  %body
    = yield
}

##
# Create empty application js file
file 'public/javascripts/application.js', %Q{// Place your javascript code here}

file 'public/stylesheets/application.css', %Q{/* Place your CSS code here */}


inside('test') do
  run 'mkdir factories'
end


rake 'db:migrate'


##
# Set up git repository
git :add => '.'
git :commit => "-a -m 'Initial project commit from template.'"