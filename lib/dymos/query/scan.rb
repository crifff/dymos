module Dymos
  module Query
    class Scan < ::Dymos::Query::Builder

      def limit(params)
        @limit = params
        self
      end

      def exclusive_start_key(params)
        @exclusive_start_key = params
        self
      end

      def query
        data = {
            table_name: @table_name.to_s,
        }
        data[:limit] = @limit if @limit.present?
        data[:exclusive_start_key] = @exclusive_start_key if @exclusive_start_key.present?
        data
      end
    end
  end
end