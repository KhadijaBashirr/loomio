# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'cucumber/rails'
require 'spork'

require 'email_spec' # add this line if you use spork
require 'email_spec/cucumber'
#require 'capybara-screenshot/cucumber'

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.

ENV["RAILS_ENV"] ||= test
Capybara.default_selector = :css
ActionController::Base.allow_rescue = false
Cucumber::Rails::Database.javascript_strategy = :truncation
Capybara.default_driver = :rack_test
Capybara.default_wait_time = 20

Before do |scenario|
  @feature_name = scenario.feature.title
  @scenario_name = scenario.title
end
