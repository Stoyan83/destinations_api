require 'rails_helper'

RSpec.describe "Api::V1::Trips#index", type: :request do
  let!(:trip1) { create(:trip, name: "Alps", rating: 5) }
  let!(:trip2) { create(:trip, name: "Beach", rating: 3) }
  let!(:trip3) { create(:trip, name: "City", rating: 1) }

  describe "GET /api/v1/trips" do
    subject(:make_request) { get "/api/v1/trips", params: params }

    let(:json) { JSON.parse(response.body) }
    let(:data) { json["trips"] || [] }
    let(:meta) { json["meta"] || {} }

    context "without filters" do
      let(:params) { {} }

      it "returns first page with default 10 per page and ordered by name asc" do
        make_request

        expect(response).to have_http_status(:ok)
        expect(data.size).to eq(3)

        names = data.map { |t| t["name"] }
        expect(names).to eq(%w[Alps Beach City])

        expect(meta["current_page"]).to eq(1)
        expect(meta["per_page"]).to eq(10)
        expect(meta["total_pages"]).to eq(1)
        expect(meta["total_records"]).to eq(3)
      end
    end

    context "with combined filters" do
      let(:params) do
        {
          search: "Beach",
          min_rating: 3,
          sort: "rating",
          direction: "desc",
          page: 1,
          per_page: 3
        }
      end

      it "returns filtered, sorted, and paginated trips" do
        make_request

        expect(response).to have_http_status(:ok)
        expect(data.size).to eq(1)
        expect(data.first["name"]).to eq("Beach")
        expect(data.first["rating"]).to be >= 3

        expect(meta["current_page"]).to eq(1)
        expect(meta["per_page"]).to eq(3)
        expect(meta["total_records"]).to eq(1)
        expect(meta["total_pages"]).to eq(1)
      end
    end

    context "with search filter" do
      let(:params) { { search: "Alps" } }

      it "returns matching trips" do
        make_request

        expect(response).to have_http_status(:ok)
        expect(data.size).to eq(1)
        expect(data.first["name"]).to eq("Alps")
      end
    end

    context "with min_rating filter" do
      let(:params) { { min_rating: 3 } }

      it "returns trips with rating >= min_rating" do
        make_request

        expect(response).to have_http_status(:ok)
        ratings = data.map { |t| t["rating"] }
        expect(ratings).to all(be >= 3)
      end
    end

    context "with sorting by rating desc" do
      let(:params) { { sort: "rating", direction: "desc" } }

      it "returns trips ordered by rating descending" do
        make_request

        expect(response).to have_http_status(:ok)
        ratings = data.map { |t| t["rating"] }
        expect(ratings).to eq([ 5, 3, 1 ])
      end
    end

    context "with sorting by name desc" do
      let(:params) { { sort: "name", direction: "desc" } }

      it "returns trips ordered by name descending" do
        make_request

        expect(response).to have_http_status(:ok)
        names = data.map { |t| t["name"] }
        expect(names).to eq(%w[City Beach Alps])
      end
    end

    context "with pagination" do
      let(:params) { { page: 1, per_page: 2 } }

      it "returns limited number of records and correct meta" do
        make_request

        expect(response).to have_http_status(:ok)
        expect(data.size).to eq(2)
        expect(meta["per_page"]).to eq(2)
        expect(meta["current_page"]).to eq(1)
        expect(meta["total_records"]).to eq(3)
      end
    end

    context "with unpermitted query parameter" do
      let(:params) { { foo: "bar" } }

      it "returns 400 error with proper structure" do
        make_request

        expect(response).to have_http_status(:bad_request)

        error = JSON.parse(response.body)
        expect(error["error"]["code"]).to eq("unpermitted_parameters")
        expect(error["error"]["message"]).to include("foo")
      end
    end
  end
end
