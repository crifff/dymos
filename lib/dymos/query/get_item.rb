module Dymos
  module Query
    class GetItem
      def initialize
        @query={}
      end

      def name(value)
        @query[:table_name] = value
        self
      end

      def key(value)
        @query[:key] = value.deep_stringify_keys
        self
      end

      def attributes(*value)
        @query[:attributes_to_get] = value
        self
      end

      def consistent_read(value)
        @query[:consistent_read] = value
        self
      end

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

      def build(value={})
         @query.merge value
      end
    end
  end
end