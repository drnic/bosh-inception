source 'https://rubygems.org'

# Specify your gem's dependencies in inception.gemspec
gemspec

gem "settingslogic", github: "drnic/settingslogic", branch: "integration"

# gem 'knife-solo', github: 'matschaffer/knife-solo'
gem 'knife-solo', github: 'drnic/knife-solo', branch: 'continue_connecting'

group :integration do
  gem 'kitchen-ec2'
end

group :vagrant do
  gem 'kitchen-vagrant', '~> 0.10.0'
end
