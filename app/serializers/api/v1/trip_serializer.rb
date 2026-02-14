module Api
  module V1
    class TripSerializer < ActiveModel::Serializer
      attributes :id, :name, :image_url, :short_description, :long_description, :rating

      def attributes(*args)
        hash = super
        if instance_options[:collection]
          hash.slice(:id, :name, :image_url, :short_description, :rating)
        else
          hash
        end
      end
    end
  end
end
