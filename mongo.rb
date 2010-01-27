#
# MongoDB Rails template
#

# Delete unnecessary files

run "rm README"
run "rm public/images/rails.png"
run "rm public/index.html"
run "rm -f public/javascripts/*"

# Download JQuery

run "curl -s -L http://code.jquery.com/jquery-1.4.1.min.js > public/javascripts/jquery.min.js"
run "curl -s -L http://code.jquery.com/jquery-1.4.1.js > public/javascripts/jquery.js"

# Create gitignore files

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
file '.gitignore',
%q{.DS_Store
*.swp
log/*.log
tmp/**/*
tmp/tags
config/database.yml
db/*.sqlite3
}

# Initialize git repository

git :init

# Required gems

gem 'mongo_mapper'
gem 'haml'

# Initializers

file 'config/initializers/haml.rb',
%q[Haml::Template.options[:format] = :html5
Haml::Template.options[:escape_html] = false
]

file 'config/initializers/action_mailer_config.rb',
%q[ActionMailer::Base.smtp_settings = {
  :address => "smtp.blueberryapps.com",
  :port    => 25,
  :domain  => "blueberryapps.com"
}
]

file 'config/initializers/mongo_mapper.rb',
%q{db_config = YAML::load(File.read(File.join(Rails.root, "/config/mongodb.yml")))
mongo     = db_config[Rails.env]

if mongo && mongo['adapter'] == 'mongodb'
  MongoMapper.database   = mongo['database']
  MongoMapper.connection = Mongo::Connection.new(mongo['host'] || 'localhost',
                                                 mongo['port'] || 27017,
                                                 :logger => Rails.logger)

  if mongo['username'] && mongo['password']
    MongoMapper.database.authenticate(mongo['username'], mongo['password'])
  end
end

ActionController::Base.rescue_responses['MongoMapper::DocumentNotFound'] = :not_found
}

file 'config/mongodb.yml',
%q[# config/mongodb.yml
base: &base
  adapter: mongodb
  # These are needed to authenticate with your db
  #host: genesis.mongohq.com
  #username: your-username
  #password: your-password

development:
  <<: *base
  database: boards-development

test:
  <<: *base
  database: board-test

production:
  <<: *base
  database: boards-production]

# Locales

inside('config/locales') do
  run "curl -s -L http://gist.github.com/60344.txt > cs_active_record.yml"
  run "curl -s -L http://gist.github.com/60343.txt > cs_active_support.yml"
  run "curl -s -L http://gist.github.com/60342.txt > cs_action_view.yml"

end

file 'config/locales/cs.yml', 'cs:'


# Layout

run 'mkdir app/views/shared'

file 'app/views/shared/_flashes.html.haml',
%q[- flash.each do |name, msg|
  = content_tag :div, msg, :id => "flash_\#{name}"
]

file 'app/views/layouts/application.html.haml',
%q[
!!! Transitional
%html{html_attrs}

  %head
    %title= h(yield(:title) || "Mongo Project")
    %meta{"http-equiv" => "Content-Type", :content => "text/html; charset=utf-8"}
    = stylesheet_link_tag 'application'
    = javascript_include_tag 'jquery', 'application'
    = javascript_auth_token_tag
    = yield :head

  %body
    = render :partial => 'shared/flashes'
    #content= yield
]

# Create empty application JavaScript & CSS files

file 'public/javascripts/application.js', %Q{$(function() { /* jquery code here */ });}
file 'public/stylesheets/application.css', %Q{/* Place your CSS code here */}

# Generate Cucumber files

generate 'cucumber'

# Set up git repository

git :add => '.'
git :commit => "-a -m 'Initial project commit from template.'"

