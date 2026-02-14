module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(filter_params = {}, *associations)
      results = where(nil)
      results = results.includes(*associations) if associations.any?

      order_by = filter_params.delete(:sort)
      direction = filter_params.delete(:direction)&.downcase == 'desc' ? :desc : :asc

      results = apply_filters(results, filter_params)
      results = apply_ordering(results, order_by, direction)

      results
    end

    def sortable_columns
      %w[name rating]
    end

    private

    def apply_filters(results, filter_params)
      filter_params.each do |key, value|
        next unless value.present?

        scope_name = "filter_by_#{key}"
        results = results.public_send(scope_name, value) if respond_to?(scope_name)
      end

      results
    end

    def apply_ordering(results, order_by, direction)
      column = sortable_columns.include?(order_by.to_s) ? order_by.to_s : 'name'
      scope_name = "order_by_#{column}"

      if results.respond_to?(scope_name)
        results.public_send(scope_name, direction)
      else
        results.order(id: :asc)
      end
    end
  end
end
