require 'swagger_helper'

RSpec.describe 'Trips API', type: :request do
  path '/api/v1/trips' do
    post 'Creates a trip' do
      tags 'Trips'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          trip: {
            type: :object,
            properties: {
              name: { type: :string, example: "Forbidden Island" },
              image_url: { type: :string, example: "https://example.com/image.jpg" },
              short_description: { type: :string, example: "Secret place" },
              long_description: { type: :string, nullable: true, example: "Very secret place" },
              rating: { type: :integer, example: 1 }
            },
            required: %w[name image_url short_description rating]
          }
        },
        required: ['trip']
      }

      response '201', 'trip created', swagger_doc: 'v1/swagger.yaml' do
        let(:payload) do
          {
            trip: {
              name: "Forbidden Island",
              image_url: "https://example.com/image.jpg",
              short_description: "Secret place",
              long_description: "Very secret place",
              rating: 5
            }
          }
        end

        schema type: :object,
               properties: {
                 trip: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     name: { type: :string, example: "Forbidden Island" },
                     image_url: { type: :string, example: "https://example.com/image.jpg" },
                     short_description: { type: :string, example: "Secret place" },
                     long_description: { type: :string, nullable: true, example: "Very secret place" },
                     rating: { type: :integer, example: 1 }
                   },
                   required: %w[id name image_url short_description rating]
                 }
               },
               required: ['trip']

        run_test!
      end

      response '422', 'invalid parameters', swagger_doc: 'v1/swagger.yaml' do
        let(:payload) do
          {
            trip: {
              name: "",
              image_url: "",
              short_description: "",
              rating: nil
            }
          }
        end

        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string, example: "validation_error" },
                     message: { type: :string, example: "Name can't be blank" }
                   },
                   required: %w[code message]
                 }
               },
               required: ['error']

        run_test!
      end

      response '400', 'unpermitted parameters', swagger_doc: 'v1/swagger.yaml' do
        let(:payload) do
          {
            trip: {
              name: "Forbidden Island",
              image_url: "https://example.com/image.jpg",
              short_description: "Secret place",
              rating: 5,
              hack_param: "bad"
            }
          }
        end

        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string, example: "unpermitted_parameters" },
                     message: { type: :string, example: "Found unpermitted parameter: hack_param" }
                   },
                   required: %w[code message]
                 }
               },
               required: ['error']

        run_test!
      end
    end
  end
end
