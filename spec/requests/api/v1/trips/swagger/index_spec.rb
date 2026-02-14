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
        let!(:trip1) { create(:trip, name: "Alps", rating: 5) }
        let!(:trip2) { create(:trip, name: "Beach", rating: 3) }
        let!(:trip3) { create(:trip, name: "City", rating: 1) }

        schema type: :object,
               properties: {
                 trips: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       rating: { type: :integer }
                     },
                     required: ['id', 'name', 'rating']
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     per_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_records: { type: :integer }
                   },
                   required: ['current_page', 'per_page', 'total_pages', 'total_records']
                 }
               },
               required: ['trips', 'meta']

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
                     code: { type: :string },
                     message: { type: :string }
                   },
                   required: ['code', 'message']
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
