module Api
  module V1
    class TripsController < ApplicationController
      include Paginatable

      def index
        filtered = Trip.filter(filter_params)
        paginated = paginate(filtered)

        render json: paginated[:data],
               each_serializer: Api::V1::TripSerializer,
               collection: true,
               meta: paginated[:meta]
      end

      def show
        trip = Trip.find(params[:id])
        render json: trip, serializer: Api::V1::TripSerializer
      end

      private

      def filter_params
        params.permit(:search, :min_rating, :sort, :direction, :page, :per_page)
      end
    end
  end
end
