module Dymos
  module Query
    class GetItem < ::Dymos::Query::Builder

      def key(params)
        @key = params
        self
      end

      def query
        {
            table_name: @table_name.to_s,
            key: @key,
            consistent_read: true,
        }
      end
    end
  end
end