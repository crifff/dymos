module Dymos
  module Query
    class Scan
      def initialize
        @query={}
      end

      def name(value)
        @query[:table_name] = value
        self
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
        value.map { |v| add_filter(v) }
        @query[:conditional_operator] = operator.to_s.upcase
        self
      end

      def add_filter(value)
        @query[:scan_filter] ||= {}
        @query[:scan_filter].store(*_add_filter(value))
        self
      end

      def _add_filter(value)
        [value[0].to_s, {
                        attribute_value_list: [*value[2]],
                        comparison_operator: value[1].to_s.upcase
                      }
        ]
      end

      def filter_operator(value)
        @query[:conditional_operator] = value.to_s.upcase
        self
      end

      def start_key(value)
        @query[:exclusive_start_key] = value.deep_stringify_keys
        self
      end

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

      def build(value={})
        @query.merge value
      end

    end
  end
end