module Dymos
  module Query
    class Query < ::Dymos::Query::Builder

      def key_conditions(params)
        @key = Hash[params.map do |name, expression|
          operator, values = expression.split(' ', 2)
          if values.nil?
            [name, ::Dymos::Query::Expect.new.condition(operator, nil).data(true)]
          else
            value1, value2 = values.split(' ')
            if value2.present?
              [name, ::Dymos::Query::Expect.new.condition(operator, values).data(true)]
            else
              [name, ::Dymos::Query::Expect.new.condition(operator, value1).data(true)]
            end
          end

        end]
        self
      end

      def index_name(name)
        @index_name =name
        self
      end

      def query
        {
            table_name: @table_name.to_s,
            index_name: @index_name.to_s,
            key_conditions: @key,
            consistent_read: false
        }
      end
    end
  end
end