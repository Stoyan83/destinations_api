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
          only_actions = options[:only]
          except_actions = options[:except]

          permitted_query_params << QueryParamRule.new(params, only: only_actions, except: except_actions)
        end
      end

      private

      def reject_invalid_query_parameters!
        return unless self.class.permitted_query_params.any? { |rule| rule.applies_to?(action_name.to_sym) }

        normalized_keys = request.query_parameters.keys.map(&:to_s)
        allowed_keys = valid_query_parameters

        unpermitted = normalized_keys - allowed_keys
        raise ActionController::UnpermittedParameters.new(unpermitted) if unpermitted.any?
      end

      def valid_query_parameters
        current_action = action_name.to_sym
        self.class.permitted_query_params
            .select { |rule| rule.applies_to?(current_action) }
            .flat_map(&:parameters).map(&:to_s)
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
