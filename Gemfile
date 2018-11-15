source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.4.2'
gem 'rails'       , '~> 5.2.1'
gem 'pg'          , '>= 0.18', '< 2.0'
gem 'puma'        , '~> 3.11'
gem 'sass-rails'  , '~> 5.0'
gem 'uglifier'    , '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks'  , '~> 5'
gem 'jbuilder'    , '~> 2.5'
gem 'bootsnap'    , '~> 1.3', '>= 1.3.2', require: false
gem 'devise'      , '~> 4.5'
gem 'simple_form' , '~> 4.0', '>= 4.0.1'
gem 'bootstrap'   , '~> 4.1', '>= 4.1.3'
gem 'jquery-rails'
gem 'whenever'    , :require => false
gem 'rugged'      , '~> 0.27.5'
gem 'faker'       , '~> 1.9', '>= 1.9.1'
gem 'github_api'  , '~> 0.18.2'
gem 'redcarpet'   , '~> 3.4'
gem 'resque', '~> 2.0', require: 'resque/server'

group :development, :test do
  gem 'byebug'       , platforms: [:mri, :mingw, :x64_mingw]
  gem 'letter_opener', '~> 1.6'
end

group :development do
  gem 'web-console'          , '>= 3.3.0'
  gem 'listen'               , '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano'           , '~> 3.11'
  gem 'capistrano-rails'     , '~> 1.4'
  gem 'capistrano-rbenv'     , '~> 2.1', '>= 2.1.4'
  gem 'capistrano-passenger' , '~> 0.2.0'
end

group :test do
  gem 'minitest'          , '~> 5.11', '>= 5.11.3'
  gem 'minitest-reporters', '~> 1.3', '>= 1.3.5'
  gem 'simplecov'         , require: false, group: :test
  gem 'm'                 , '~> 1.5', '>= 1.5.1'
  gem 'capybara'          , '>= 2.15'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
