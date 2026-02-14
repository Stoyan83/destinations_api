require 'swagger_helper'

RSpec.describe 'Trips API', type: :request do
  path '/api/v1/trips/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Trip ID'
    parameter name: :foo, in: :query, type: :string, required: false, description: 'Unpermitted query param example'

    get 'Retrieves a trip' do
      tags 'Trips'
      produces 'application/json'

      response '200', 'trip found', swagger_doc: 'v1/swagger.yaml' do
        let(:trip) { create(:trip, name: "Alps", rating: 5) }
        let(:id) { trip.id }

        schema type: :object,
               properties: {
                 trip: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     rating: { type: :integer }
                   },
                   required: ['id', 'name', 'rating']
                 }
               },
               required: ['trip']

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['trip']['id']).to eq(trip.id)
          expect(data['trip']['name']).to eq("Alps")
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
                     code: { type: :string },
                     message: { type: :string }
                   },
                   required: ['code', 'message']
                 }
               },
               required: ['error']

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']['code']).to eq('not_found')
          expect(data['error']['message']).to eq('The record you were looking for could not be found.')
        end
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
