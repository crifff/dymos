module Dymos
  module Query
    class DeleteItem < ::Dymos::Query::Builder

      # @param [String] name
      # @return [self]
      def key(name)
        @key = name
        self
      end

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

      def query
        data = {
            table_name: @table_name.to_s,
            key: @key,
            return_values: @return_values || 'ALL_OLD'
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