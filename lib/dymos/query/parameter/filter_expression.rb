module Dymos
  module Query
    module Parameter
      module FilterExpression
        def filter_expression(value)
          @query[:filter_expression] = value
          self
        end

        def expression_attribute_names(value)
          names = value.deep_stringify_keys.map do |k, v|
            k="##{k}" unless k[0] == "#"
            [k, v]
          end
          @query[:expression_attribute_names] = Hash[*names.flatten]
          self
        end

        def expression_attribute_values(value)
          values = value.deep_stringify_keys.map do |k, v|
            k=":#{k}" unless k[0] == ":"
            [k, v]
          end
          @query[:expression_attribute_values] = Hash[*values.flatten]
          self
        end

        alias :expression :filter_expression
        alias :bind_names :expression_attribute_names
        alias :bind_values :expression_attribute_values

      end
    end
  end
end