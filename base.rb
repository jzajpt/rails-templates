#
# Delete unnecessary files
run "rm README"
run "rm public/robots.txt"
run "rm public/favicon.ico"
run "rm public/images/rails.png"
run "rm public/index.html"
run "rm -f public/javascripts/*"

##
# Download JQuery
run "curl -s -L http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js > public/javascripts/jquery.js"

##
# Create gitignore files
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
file '.gitignore', 
%q{.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
}

##
# Initialize git repository
git :init


##
# Install plugins
plugin 'i18n_label',
  :git => 'git://github.com/iain/i18n_label.git'#, :submodule => true
# plugin 'blueberry_scaffold',
  # :git => 'git://github.com/jzajpt/blueberry_scaffold.git'#, :submodule => true

##
# Setup gem requirements
gem 'cucumber', :version => '>= 0.2.2'
gem "thoughtbot-shoulda",
  :lib => "shoulda",
  :source => "http://gems.github.com",
  :version => '>= 2.10.1'
gem 'thoughtbot-factory_girl',
  :lib => 'factory_girl',
  :source => 'http://gems.github.com',
  :version => '>= 1.2.0'
gem 'mocha'
gem 'rubyist-aasm',
  :lib => 'aasm',
  :source => 'http://gems.github.com'
gem 'mislav-will_paginate',
  :lib => 'will_paginate',
  :source => 'http://gems.github.com',
  :version => '>= 2.3.8'

##
# Add own initializers
file 'config/initializers/noisy_attr_accessible.rb', 
%q{ActiveRecord::Base.class_eval do
  def log_protected_attribute_removal(*attributes)
    raise "Can't mass-assign these protected attributes: #{attributes.join(', ')}"
  end
end}

##
# Fetch Czech locales
inside('config/locales') do
  run "curl -s -L http://gist.github.com/60344.txt > cs_active_record.yml"
  run "curl -s -L http://gist.github.com/60343.txt > cs_active_support.yml"
  run "curl -s -L http://gist.github.com/60342.txt > cs_action_view.yml"
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
# Create application layout
file 'app/views/layouts/application.html.erb', 
%Q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title><%= h(yield(:title) || "Untitled") %></title>
    <%= stylesheet_link_tag 'application', :media => 'all' %>
    <%= javascript_include_tag 'jquery', 'application' %>
  </head>
  <body>
    <div id="container">
      <%= render :partial => 'layouts/flashes' %>
      <%= yield %>
    </div>
  </body>
</html>
}

file 'app/views/layouts/_flashes.html.erb', 
%Q{<%- flash.each do |name, msg| -%>
  <%= content_tag :div, msg, :id => "flash_\#{name}" %>
<%- end -%>
}

##
# Create empty application js file
file 'public/javascripts/application.js', %Q{$(document).ready(function() { /* jquery code here */ });}
file 'public/stylesheets/application.css', %Q{/* Place your CSS code here */}

run 'mkdir test/factories'

rake 'db:migrate'

#
# Generate Cucumber files
generate 'cucumber'


##
# Set up git repository
git :add => '.'
git :commit => "-a -m 'Initial project commit from template.'"