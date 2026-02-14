module Api
  module V1
    class BaseController < ApplicationController
      include Api::V1::Paginatable
      include Api::V1::QueryParameterValidation
      include Api::V1::ErrorHandling
    end
  end
end
