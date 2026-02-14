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

    private

    def apply_filters(results, filter_params)
      filter_params.each do |key, value|
        next unless value.present?
        scope_name = "filter_by_#{key}"
        results = results.public_send(scope_name, value) if respond_to?(scope_name, true)
      end
      results
    end

    def apply_ordering(results, order_by, direction)
      return results.order(name: :asc) if order_by.blank? && column_names.include?('name')

      fetch_order_scope(order_by, direction) || results
    end

    def fetch_order_scope(order_by, direction)
      scope_name = "order_by_#{order_by}"
      return public_send(scope_name, direction) if respond_to?(scope_name, true)
      return order(order_by => direction) if column_names.include?(order_by.to_s)
      nil
    end
  end
end
