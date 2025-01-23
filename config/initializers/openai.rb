require 'openai'
# This file is not used in the actual application (except for the configuration)

OpenAI.configure do |config|
  config.access_token = Rails.application.credentials.csskitchen[:openai][:api_key]
  config.organization_id = Rails.application.credentials.csskitchen[:openai][:organization_id]
  config.log_errors = true
end