# spec/swagger_helper.rb
require 'rails_helper'

RSpec.configure do |config|
    config.openapi_root = Rails.root.join('swagger').to_s
    config.openapi_specs = {
      'v1/swagger.yaml' => {
        openapi: '3.0.1',
        info: { title: 'Destinations API V1', version: 'v1' },
        paths: {},
        servers: [{ url: 'http://localhost:3000', description: 'Local server' }]
      }
    }
    config.openapi_format = :yaml

  
    config.after(:example, type: :request) do |example|
      if example.metadata[:swagger_doc]
        puts "Example ran: #{example.description}"
        puts "Swagger doc: #{example.metadata[:swagger_doc]}"
      end
    end
  end
  