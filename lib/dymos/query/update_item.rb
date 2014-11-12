module Dymos
  module Query
    class UpdateItem < Base
      def command
        'update_item'
      end

      def key(value)
        @query[:key] = value.deep_stringify_keys
        self
      end

      def add(column, value)
        add_attribute_updates(column, :add, value)
        self
      end

      def put(column, value)
        add_attribute_updates(column, :put, value)
        self
      end

      def delete(column, value)
        add_attribute_updates(column, :delete, value)
        self
      end

      def attribute_updates(*value)
        value.map { |v| add_attribute_updates(*v) }
        self
      end

      def add_attribute_updates(*value)
        if value.count == 2
          column, operator, value = value[0], :put, value[1]
        else
          column, operator, value = value
        end
        @query[:attribute_updates] ||= {}
        @query[:attribute_updates].store(*_attribute_updates(column, operator, value))
        self
      end

      def _attribute_updates(column, action, value)
        [column.to_s, {
                      value: value,
                      action: action.to_s.upcase
                    }
        ]
      end

      def expected(value)
        value.map { |v| add_expected(*v) }
        self
      end

      def add_expected(*value)
        if value.count == 2
          column, operator, value = value[0], :eq, value[1]
        else
          column, operator, value = value
        end
        @query[:expected] ||= {}
        @query[:expected].store(*_add_expected(column, operator, value))
        self
      end

      def _add_expected(column, operator, value)
        [column.to_s, {
                      attribute_value_list: ([:BETWEEN, :IN].include? operator) ? [*value] : [value],
                      comparison_operator: operator.to_s.upcase
                    }
        ]
      end

      def conditional_operator(value)
        @query[:conditional_operator] = value.to_s.upcase
        self
      end


      def return_values(value)
        @query[:return_values] = value.to_s.upcase
        self
      end

      def return_consumed_capacity(value)
        @query[:return_consumed_capacity] = value.to_s.upcase
        self
      end

      def return_item_collection_metrics(value)
        @query[:return_item_collection_metrics] = value.to_s.upcase
        self
      end

      def update_expression(value)
        @query[:update_expression] = value
        self
      end

      def condition_expression(value)
        @query[:condition_expression] = value
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