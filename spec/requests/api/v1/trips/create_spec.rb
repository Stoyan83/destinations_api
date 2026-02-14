require 'rails_helper'

RSpec.describe "Api::V1::Trips#create", type: :request do
  let(:valid_attributes) do
    {
      name: "Forbidden Island",
      image_url: "https://example.com/image.jpg",
      short_description: "Secret place",
      long_description: "Very secret place",
      rating: 5
    }
  end

  let(:invalid_attributes) do
    {
      name: "",
      image_url: "",
      short_description: "",
      rating: nil
    }
  end

  describe "POST /api/v1/trips" do
    context "with valid parameters" do
      it "creates a new Trip and returns 201" do
        expect {
          post "/api/v1/trips", params: { trip: valid_attributes }, as: :json
        }.to change(Trip, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["trip"]["name"]).to eq("Forbidden Island")
        expect(json["trip"]["rating"]).to eq(5)
      end

      it "strips leading/trailing whitespace from string attributes" do
        attrs = valid_attributes.transform_values { |v| v.is_a?(String) ? "  #{v}  " : v }

        post "/api/v1/trips", params: { trip: attrs }, as: :json

        expect(response).to have_http_status(:created)
        trip = Trip.last
        expect(trip.name).to eq("Forbidden Island")
        expect(trip.image_url).to eq("https://example.com/image.jpg")
        expect(trip.short_description).to eq("Secret place")
        expect(trip.long_description).to eq("Very secret place")
      end
    end

    context "with invalid parameters" do
      it "does not create a Trip and returns 422" do
        expect {
          post "/api/v1/trips", params: { trip: invalid_attributes }, as: :json
        }.not_to change(Trip, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to be_present
      end

      it "rejects non-integer rating" do
        attrs = valid_attributes.merge(rating: 4.5)
        post "/api/v1/trips", params: { trip: attrs }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]["message"]).to include("must be a whole number between 1 and 5")
      end

      it "rejects rating out of bounds" do
        attrs = valid_attributes.merge(rating: 10)
        post "/api/v1/trips", params: { trip: attrs }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]["message"]).to include("must be a whole number between 1 and 5")
      end

      it "allows long_description to be nil" do
        attrs = valid_attributes.merge(long_description: nil)
        post "/api/v1/trips", params: { trip: attrs }, as: :json

        expect(response).to have_http_status(:created)
        trip = Trip.last
        expect(trip.long_description).to be_nil
      end

      it "rejects duplicate trip name" do
        Trip.create!(valid_attributes)
        post "/api/v1/trips", params: { trip: valid_attributes }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]["message"]).to include("Name has already been taken")
      end
    end

    context "with unpermitted parameters" do
      it "returns an unpermitted parameters error" do
        post "/api/v1/trips",
             params: { trip: valid_attributes.merge(hack_param: "bad") }.to_json,
             headers: { "Content-Type" => "application/json" }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]["code"]).to eq("unpermitted_parameters")
        expect(json["error"]["message"]).to include("hack_param")
      end
    end
  end
end
