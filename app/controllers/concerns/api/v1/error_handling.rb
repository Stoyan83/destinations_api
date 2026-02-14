module Api
  module V1
    module ErrorHandling
      extend ActiveSupport::Concern

      included do
        rescue_from ActionController::UnpermittedParameters, with: :handle_unpermitted_parameters
        rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
        rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
      end

      private

      def handle_unpermitted_parameters(exception)
        unpermitted_params = exception.params
        formatted_params = unpermitted_params.map(&:to_s).join(", ")

        error_response = {
          error: {
            code: I18n.t("api.errors.unpermitted_parameters.code"),
            message: I18n.t(
              "api.errors.unpermitted_parameters.message",
              params: formatted_params
            )
          }
        }

        render json: error_response, status: :bad_request
      end

      def handle_record_not_found(_exception)
        error_response = {
          error: {
            code: I18n.t("api.errors.not_found.code"),
            message: I18n.t("api.errors.not_found.message")
          }
        }

        render json: error_response, status: :not_found
      end

      def handle_record_invalid(exception)
        record = exception.record

        messages = record.errors.messages.map do |attr, msgs|
          msgs.map { |msg| "#{record.class.human_attribute_name(attr)} #{msg}" }
        end.flatten

        error_response = {
          error: {
            code: I18n.t("api.errors.record_invalid.code"),
            message: messages.join(", ")
          }
        }

        render json: error_response, status: :unprocessable_entity
      end
    end
  end
end
