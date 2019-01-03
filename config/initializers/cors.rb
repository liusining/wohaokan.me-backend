# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'stg.wohaokan.me', 'wohaokan.me', 'www.wohaokan.me', 'localhost:9901', '192.168.1.8:9901', '100.66.162.35:9901'

    resource '*',
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options, :head],
             max_age: 600,
             credentials: true
  end
end
