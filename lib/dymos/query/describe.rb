module Dymos
  module Query
    class Describe < ::Dymos::Query::Builder
      def query
        {
            table_name: @table_name.to_s
        }
      end
    end
  end
end