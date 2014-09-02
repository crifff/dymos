module Dymos
  module Query
    class Builder
      attr_accessor :table_name, :command, :query

      def initialize(command, table_name=nil)
        @command = command
        @table_name = table_name if table_name.present?
        self
      end

      def query

      end

      def execute(client)
        begin
          res = client.send command, query
        rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
          return false
        end
        res.data
      end
    end
  end
end