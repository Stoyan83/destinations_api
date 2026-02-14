module Api
    module V1
      module ErrorHandling
        extend ActiveSupport::Concern
  
        included do
          rescue_from ActionController::UnpermittedParameters, with: :handle_unpermitted_parameters
          rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
        end
  
        private

        def handle_unpermitted_parameters(exception)
          unpermitted_params = exception.params
          formatted_params = unpermitted_params.map { |param| "#{param}" }.join(', ')
  

          error_response = {
            error: {
              code: "unpermitted_parameters",
              message: "The following query parameters are not permitted: #{formatted_params}"
            }
          }
  
          render json: error_response, status: :bad_request
        end
  
        def handle_record_not_found(exception)
          error_response = {
            error: {
              code: "not_found",
              message: "The record you were looking for could not be found."
            }
          }
  
          render json: error_response, status: :not_found
        end
      end
    end
  end
  