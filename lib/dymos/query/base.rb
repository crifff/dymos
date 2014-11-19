module Dymos
  module Query
    class Base
      def initialize
        @query={}
      end

      def command

      end

      def name(value)
        @query[:table_name] = value
        self
      end

      def build(value={})
        value = ::Dymos::Config.default[command.to_sym].merge value
        @query.merge value
      end

      protected
      def parse_condition(*values)
        if values[1].class == Symbol
          if values.count == 2
            column, operator, value = values[0], values[1], nil
          else
            column, operator, value = values
          end
        else
          column, operator, value = values[0], :eq, values[1]
        end

        [column, operator, value]
      end
    end
  end
end