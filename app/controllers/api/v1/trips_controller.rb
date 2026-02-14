module Api
  module V1
    class TripsController < Api::V1::BaseController
      allow_query_parameters! :search, :min_rating, :sort, :direction, :page, :per_page, only: :index
      allow_query_parameters! :id, only: :show

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
