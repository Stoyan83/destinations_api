module Api
  module V1
    class TripsController < Api::V1::BaseController
      allow_query_parameters! :search, :min_rating, :sort, :direction, :page, :per_page, only: :index
      allow_query_parameters! :id, only: :show

      def index
        cache_key = "trips_index/" + Digest::MD5.hexdigest(filter_params.to_h.sort.to_h.to_s)

        rendered_json = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          filtered = Trip.filter(filter_params)
          paginated = paginate(filtered)

          ActiveModelSerializers::SerializableResource.new(
            paginated[:data],
            each_serializer: Api::V1::TripSerializer,
            collection: true,
            meta: paginated[:meta]
          ).as_json
        end

        render json: rendered_json, status: :ok
      end

      def show
        trip = Trip.find(params[:id])

        render json: trip, serializer: Api::V1::TripSerializer
      end

      def create
        permit_body_params(create_params)
        trip = Trip.create!(create_params)

        render json: trip, serializer: Api::V1::TripSerializer, status: :created
      end

      private

      def create_params
        params.require(:trip).permit(:name, :image_url, :short_description, :long_description, :rating)
      end

      def filter_params
        params.permit(:search, :min_rating, :sort, :direction, :page, :per_page)
      end
    end
  end
end
