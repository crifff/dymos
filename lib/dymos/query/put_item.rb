module Dymos
  module Query
    class PutItem < Dymos::Query::Builder

      def item(params)
        @item = params
        self
      end

      def expected(params)
        @expected = Hash[params.map do |name, expression|
          operator, values = expression.split(' ', 2)
          if values.nil?
            value1 = operator
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
            item: @item,
            return_values: @return_values || 'ALL_OLD',
            # return_consumed_capacity: @return_consumed_capacity || 'TOTAL',
            # return_item_collection_metrics: @return_item_collection_metrics || 'SIZE',
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