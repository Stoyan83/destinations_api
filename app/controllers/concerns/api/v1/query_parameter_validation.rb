module Api
  module V1
    module QueryParameterValidation
      extend ActiveSupport::Concern

      included do
        before_action :reject_invalid_query_parameters!

        def self.permitted_query_params
          @permitted_query_params ||= []
        end

        def self.allow_query_parameters!(*params)
          options = params.extract_options!

          allowed_actions = options[:only]
          excluded_actions = options[:except]

          permitted_query_params << QueryParamRule.new(params, only: allowed_actions, except: excluded_actions)
        end
      end

      private

      def reject_invalid_query_parameters!
        if self.class.permitted_query_params.any? { |rule| rule.applies_to?(action_name.to_sym) }
          invalid_parameters = request.query_parameters.keys - valid_query_parameters

          raise ActionController::UnpermittedParameters.new(invalid_parameters) if invalid_parameters.any?
        end
      end

      def valid_query_parameters
        current_action = action_name.to_sym

        self.class.permitted_query_params.select { |rule| rule.applies_to?(current_action) }
          .flat_map(&:parameters)
          .map { |param| param.to_s.camelize(:lower) }
      end
    end
  end
end


class QueryParamRule
  attr_reader :parameters

  def initialize(params, only: nil, except: nil)
    @parameters = params.flatten
    @condition = build_condition(only, except)
  end

  def applies_to?(action)
    @condition.call(action)
  end

  private

  def build_condition(only, except)
    if only
      ->(action) { Array(only).include?(action) }
    elsif except
      ->(action) { !Array(except).include?(action) }
    else
      ->(_) { true }
    end
  end
end
