require 'rails_helper'

RSpec.describe "Api::V1::Trips#show", type: :request do
  let!(:trip) { create(:trip, name: "Alps", rating: 5) }

  describe "GET /api/v1/trips/:id" do
    subject(:make_request) { get "/api/v1/trips/#{trip_id}", params: params }

    let(:params) { {} }
    let(:json) { JSON.parse(response.body) }

    context "with a valid ID" do
      let(:trip_id) { trip.id }

      it "returns the trip with 200 OK" do
        make_request

        expect(response).to have_http_status(:ok)

        expect(json["trip"]["id"]).to eq(trip.id)
        expect(json["trip"]["name"]).to eq("Alps")
        expect(json["trip"]["rating"]).to eq(5)
      end
    end

    context "with a non-existent ID" do
      let(:trip_id) { trip.id + 1000 }

      it "returns 404 not found with the correct message" do
        make_request

        expect(response).to have_http_status(:not_found)
        expect(json["error"]["code"]).to eq("not_found")
        expect(json["error"]["message"]).to eq("The record you were looking for could not be found.")
      end
    end

    context "with unpermitted query parameters" do
      let(:trip_id) { trip.id }
      let(:params) { { foo: "bar" } }

      it "returns 400 bad request with proper error structure" do
        make_request

        expect(response).to have_http_status(:bad_request)
        expect(json["error"]["code"]).to eq("unpermitted_parameters")
        expect(json["error"]["message"]).to include("foo")
      end
    end
  end
end
