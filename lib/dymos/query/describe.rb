module Dymos
  module Query
    class Describe
      def command
        'describe_table'
      end

      def initialize
        @query={}
      end

      def name(value)
        @query[:table_name] = value
        self
      end

      def build(value={})
        @query.merge value
      end

    end
  end
end