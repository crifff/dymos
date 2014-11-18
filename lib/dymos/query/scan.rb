module Dymos
  module Query
    class Scan < Base
      def command
        'scan'
      end

      def attributes(*value)
        @query[:attributes_to_get] = value
        self
      end

      def limit(value)
        @query[:limit] = value
        self
      end

      def select(value)
        @query[:select] = value
        self
      end

      def filter(value, operator='AND')
        value.map { |v| add_filter(*v) }
        filter_operator operator.to_s.upcase if value.count > 1
        self
      end

      def add_filter(*values)
        column, operator, value = parse_condition(*values)

        @query[:scan_filter] ||= {}
        @query[:scan_filter].store(*_add_filter(column, operator, value))
        filter_operator 'AND' if @query[:conditional_operator].blank? && @query[:scan_filter].count > 1
        self
      end

      def _add_filter(column, operator, value)
        hash = {
          comparison_operator: operator.to_s.upcase
        }
        hash[:attribute_value_list]=[*value] if value.present?
        [column.to_s, hash]
      end

      def filter_operator(value)
        @query[:conditional_operator] = value.to_s.upcase
        self
      end

      def exclusive_start_key(value)
        @query[:exclusive_start_key] = value.deep_stringify_keys
        self
      end

      alias :start_key :exclusive_start_key

      def return_consumed_capacity(value)
        @query[:return_consumed_capacity] = value.to_s.upcase
        self
      end

      def total_segments(value)
        @query[:total_segments] = value
        self
      end

      def segment(value)
        @query[:segment] = value
        self
      end

      def projection_expression(value)
        @query[:projection_expression] = value
        self
      end

      def filter_expression(value)
        @query[:filter_expression] = value
        self
      end

      def expression_attribute_names(value)
        @query[:expression_attribute_names] = value.deep_stringify_keys
        self
      end

      def expression_attribute_values(value)
        @query[:expression_attribute_values] = value.deep_stringify_keys
        self
      end

    end
  end
end