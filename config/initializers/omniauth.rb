Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, 
    Rails.application.credentials.dig(:csskitchen, :google_oauth, :client_id), 
    Rails.application.credentials.dig(:csskitchen, :google_oauth, :client_secret)
end

OmniAuth.config.allowed_request_methods = %i[get]
OmniAuth.config.silence_get_warning = true