require 'swagger_helper'

RSpec.describe 'Trips API', type: :request do
  path '/api/v1/trips' do
    get 'Lists trips' do
      tags 'Trips'
      produces 'application/json'

      parameter name: :search, in: :query, type: :string, required: false, description: 'Search by name'
      parameter name: :min_rating, in: :query, type: :integer, required: false, description: 'Minimum rating filter'
      parameter name: :sort, in: :query, type: :string, required: false, description: 'Sort column (name, rating)'
      parameter name: :direction, in: :query, type: :string, required: false, description: 'Sort direction (asc, desc)'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Records per page'
      parameter name: :foo, in: :query, type: :string, required: false, description: 'Unpermitted query param example'

      response '200', 'trips retrieved', swagger_doc: 'v1/swagger.yaml' do
        let!(:trip1) do
          create(:trip,
                 name: "Mount Rushmore",
                 image_url: "https://images.unsplash.com/photo-1586974772928-9e4d0efcc9ab",
                 short_description: "Famous presidential monument carved into granite.",
                 rating: 4)
        end

        let!(:trip2) { create(:trip, name: "Alps", rating: 5) }
        let!(:trip3) { create(:trip, name: "Beach", rating: 3) }

        schema type: :object,
               properties: {
                 trips: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 5 },
                       name: { type: :string, example: "Mount Rushmore" },
                       image_url: { type: :string, example: "https://images.unsplash.com/photo-1586974772928-9e4d0efcc9ab" },
                       short_description: { type: :string, example: "Famous presidential monument carved into granite." },
                       rating: { type: :integer, example: 4 }
                     },
                     required: %w[id name image_url short_description rating]
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer, example: 1 },
                     per_page: { type: :integer, example: 10 },
                     total_pages: { type: :integer, example: 1 },
                     total_records: { type: :integer, example: 3 }
                   },
                   required: %w[current_page per_page total_pages total_records]
                 }
               },
               required: %w[trips meta]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['trips'].size).to eq(3)
          expect(data['meta']['total_records']).to eq(3)
        end
      end

      response '400', 'bad request with unpermitted params', swagger_doc: 'v1/swagger.yaml' do
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

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']['code']).to eq('unpermitted_parameters')
          expect(data['error']['message']).to include('foo')
        end
      end
    end
  end
end
