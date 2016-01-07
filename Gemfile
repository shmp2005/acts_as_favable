source 'https://ruby.taobao.org/'

# Specify your gem's dependencies in acts_as_favable.gemspec
gemspec

rails_version = ENV['RAILS_VERSION'] || 'default'

rails = case rails_version
when 'master'
  { :github => 'rails/rails'}
when 'default'
  '~> 3.2.0'
else
  "~> #{rails_version}"
end

gem 'rails', rails
