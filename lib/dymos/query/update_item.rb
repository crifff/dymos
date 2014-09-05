module Dymos
  module Query
    class UpdateItem < ::Dymos::Query::Builder

      # @param [String] name
      # @return [self]
      def key(name)
        @key = name
        self
      end

      # @param [Hash] param
      # @param [String] action
      # @return [self]
      def attribute_updates(param, action="put")
        @attribute_updates||={}
        param.each { |key, value|
          @attribute_updates[key] = {
              value: value,
              action: action.upcase
          }
        }
        self
      end

      # @param [Hash] params
      # @return [self]
      def expected(params)
        @expected = Hash[params.map do |name, expression|
          operator, values = expression.split(' ', 2)
          if values.nil?
            [name, ::Dymos::Query::Expect.new.condition(operator, nil).data]
          else
            value1, value2 = values.split(' ')
            if value2.present?
              [name, ::Dymos::Query::Expect.new.condition(operator, values).data]
            else
              [name, ::Dymos::Query::Expect.new.condition(operator, value1).data]
            end
          end

        end]
        self
      end

      # @param [String] value
      # @return [self]
      def return_values(value)
        @return_values = value.upcase
        self
      end

      # @return [Hash]
      def query
        data = {
            table_name: @table_name.to_s,
            key: @key,
            attribute_updates: @attribute_updates,
            return_values: @return_values || 'ALL_NEW',
        }

        if @expected.present?
          data[:expected] = @expected
          if @expected.size > 1
            data[:conditional_operator] = @conditional_operator || 'AND'
          end
        end
        data
      end
    end
  end
end