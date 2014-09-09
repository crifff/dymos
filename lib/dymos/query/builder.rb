module Dymos
  module Query
    class Builder
      attr_accessor :table_name, :command, :query

      def initialize(command, table_name=nil, class_name=nil)
        @class_name = class_name
        @command = command
        @table_name = table_name if table_name.present?
        self
      end

      def query

      end

      def before_send_query(command, query)

      end

      def after_send_query(command, query)

      end

      def execute(client = nil)
        client ||= Aws::DynamoDB::Client.new
        begin
          before_send_query command, query
          res = client.send command, query
          after_send_query command, query
        rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
          return false
        end
        if @class_name.present?
          if res.data.respond_to? :items
            res.data[:items].map do |datum|
              obj = Object.const_get(@class_name).new
              obj.attributes = datum
              obj
            end
          elsif res.data.respond_to? :attributes
            return nil if res.attributes.nil?
            obj = Object.const_get(@class_name).new
            obj.attributes = res.attributes
            obj
          elsif res.respond_to? :data
            if res.data.respond_to? :item
              obj = Object.const_get(@class_name).new
              obj.attributes = res.data.item
              obj
            else
              res.data.to_hash
            end
          end
        else
          res.data
        end

      end
    end
  end
end