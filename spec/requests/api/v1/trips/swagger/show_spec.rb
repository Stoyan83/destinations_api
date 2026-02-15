require 'swagger_helper'

RSpec.describe 'Trips API', type: :request do
  path '/api/v1/trips/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Trip ID'
    parameter name: :foo, in: :query, type: :string, required: false, description: 'Unpermitted query param example'

    get 'Retrieves a trip' do
      tags 'Trips'
      produces 'application/json'

      response '200', 'trip found', swagger_doc: 'v1/swagger.yaml' do
        let(:trip) do
          create(:trip,
            name: "Grand Canyon National Park",
            image_url: "https://images.unsplash.com/photo-1501785888041-af3ef285b470",
            short_description: "Vast red rock canyon carved by the Colorado River.",
            long_description: "Stretching 277 miles long and over a mile deep, the Grand Canyon reveals nearly two billion years of Earth's history through its colorful layers of rock. Visitors can hike, raft, or simply take in the breathtaking views from the rim, watching the light shift across the canyon walls throughout the day.",
            rating: 5
          )
        end

        let(:id) { trip.id }

        schema type: :object,
               properties: {
                 trip: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     name: { type: :string, example: "Grand Canyon National Park" },
                     image_url: { type: :string, example: "https://images.unsplash.com/photo-1501785888041-af3ef285b470" },
                     short_description: { type: :string, example: "Vast red rock canyon carved by the Colorado River." },
                     long_description: { 
                       type: :string,
                       nullable: true,
                       example: "Stretching 277 miles long and over a mile deep, the Grand Canyon reveals nearly two billion years of Earth's history through its colorful layers of rock. Visitors can hike, raft, or simply take in the breathtaking views from the rim."
                     },
                     rating: { type: :integer, example: 5 }
                   },
                   required: %w[id name image_url short_description rating]
                 }
               },
               required: ['trip']

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['trip']['id']).to eq(trip.id)
          expect(data['trip']['name']).to eq("Grand Canyon National Park")
          expect(data['trip']['rating']).to eq(5)
        end
      end

      response '404', 'trip not found', swagger_doc: 'v1/swagger.yaml' do
        let(:id) { 0 }

        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string, example: "not_found" },
                     message: { type: :string, example: "The record you were looking for could not be found." }
                   },
                   required: %w[code message]
                 }
               },
               required: ['error']

        run_test!
      end

      response '400', 'bad request with unpermitted params', swagger_doc: 'v1/swagger.yaml' do
        let(:trip) { create(:trip) }
        let(:id) { trip.id }
        let(:foo) { 'bar' }

        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     code: { type: :string, example: "unpermitted_parameters" },
                     message: { type: :string, example: "Found unpermitted parameter: foo" }
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
