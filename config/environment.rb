# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Chapstr::Application.initialize!

APP_NAME = Rails.application.class.parent_name