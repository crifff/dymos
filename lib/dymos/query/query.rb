module Dymos
  module Query
    class Query < Base

      def command
        'query'
      end

      def index(value)
        @query[:index_name] = value.to_s
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

      def consistent_read(value)
        @query[:consistent_read] = value
        self
      end

      def where(*value)
        if value.count == 1 && value[0].is_a?(Hash)
          value[0].each { |k, v| add_conditions(k, :eq, v) }
        else
          value.each { |v| add_conditions(*v) }
        end
        self
      end

      def conditions(value)
        value.map { |v| add_conditions(*v) }
        self
      end

      def add_conditions(*values)
        column, operator, value = parse_condition(*values)
        @query[:key_conditions] ||= {}
        @query[:key_conditions].store(*_add_filter(column, operator, value))
        self
      end


      def comparison_operator(value)
        @query[:comparison_operator] = value.to_s.upcase
        self
      end

      def filter(value, operator='AND')
        value.map { |v| add_filter(*v) }
        filter_operator operator.to_s.upcase if value.count > 1
        self
      end

      def add_filter(*values)
        column, operator, value = parse_condition(*values)
        @query[:query_filter] ||= {}
        @query[:query_filter].store(*_add_filter(column, operator, value))
        filter_operator 'AND' if @query[:conditional_operator].blank? && @query[:query_filter].count > 1
        self
      end

      def _add_filter(column, operator, value)
        [column.to_s, {
                      attribute_value_list: [*value],
                      comparison_operator: operator.to_s.upcase
                    }
        ]
      end

      def filter_operator(value)
        @query[:conditional_operator] = value.to_s.upcase
        self
      end

      def asc
        scan_index_forward true
      end

      def desc
        scan_index_forward false
      end

      def scan_index_forward(value)
        @query[:scan_index_forward] = value
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

      def projection_expression(value)
        @query[:projection_expression] = value
        self
      end

      def expression_attribute_names(value)
        @query[:expression_attribute_names] = value.deep_stringify_keys
        self
      end
    end
  end
end