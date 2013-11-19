# Gemfile compiled by devise contributors
source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '3.2.13'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem "therubyracer"
  gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
  #gem 'twitter-bootstrap-rails'
  gem 'anjlab-bootstrap-rails', :require => 'bootstrap-rails',
                          :github => 'anjlab/bootstrap-rails'
end

group :production do
	gem 'thin'
end 

gem 'jquery-rails'
gem "mongoid", "~> 3.1.2"
gem "bson_ext"
gem "rspec-rails", ">= 2.12.2", :group => [:development, :test]
gem "database_cleaner", ">= 1.0.0.RC1", :group => [:development, :test]
gem "mongoid-rspec", ">= 1.7.0", :group => :test
gem "email_spec", ">= 1.4.0", :group => :test
gem "cucumber-rails", ">= 1.3.1", :group => :test, :require => false
gem "launchy", ">= 2.2.0", :group => :test
gem "capybara", ">= 2.0.3", :group => :test
gem "factory_girl_rails", ">= 4.2.0", :group => [:development, :test]
gem "devise", "~> 2.2.3"	# user signup and authentication mechanics
gem "quiet_assets", ">= 1.0.2", :group => :development
gem "figaro", ">= 0.6.3"
gem "better_errors", ">= 0.7.2", :group => :development
gem "binding_of_caller", ">= 0.7.1", :group => :development, :platforms => [:mri_19, :rbx]

# omniauth, facebook, httparty and mongo follow model
gem 'omniauth'
gem 'omniauth-facebook'
gem 'httparty'
gem 'mongo_followable', '~>0.3.2'
gem 'mongo_joinable', :path => "lib/joinable" # allows join-ability to events
gem 'sidekiq' # run code in background using threads; provides concurrency
gem 'kiqstand' # ensures that MongoDB sessions are disconnected after each worker runs; helps avoid overloading mongo
gem 'sinatra', require: false # required by sidekiq web app
gem 'slim' # required by sidekiq web app
gem 'mongo_invitable', :path => "lib/invitable" # keeps track of invites for events
gem 'fb-channel-file' # Improves performance of FB Javascript SDK (recommended by FB)
