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

      def raw_execute(client=nil)
        client ||= Aws::DynamoDB::Client.new
        begin
          before_send_query command, query
          res = client.send command, query
          after_send_query command, query
        rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
          return false
        end
        res
      end

      def execute(client = nil)
        res = raw_execute client

        return false unless res

        if @class_name.present?
          if res.data.respond_to? :items # scan, query
            metadata = extract(res, :items)
            res.data[:items].map do |datum|
              obj = Object.const_get(@class_name).new(datum)
              obj.metadata = metadata
              obj.new_record = false
              obj
            end
          elsif res.data.respond_to? :attributes # put_item, update_item
            return nil if res.attributes.nil?
            obj = Object.const_get(@class_name).new(res.attributes)
            obj.metadata = extract(res, :attributes)
            obj
          elsif res.respond_to? :data
            if res.data.respond_to? :item # get_item, delete_item
              return nil if res.data.item.nil?
              obj = Object.const_get(@class_name).new(res.data.item)
              obj.metadata = extract(res, :item)
              obj.new_record = false
              obj
            else
              res.data.to_hash # describe
            end
          end
        else
          res.data.to_hash #list_tables
        end

      end

      def extract(res, ignoreKey)
        keys = res.data.members.reject { |a| a == ignoreKey }
        array=keys.map { |k| [k, res.data[k]] }
        array.reduce({}) { |hash, value| hash.merge({value[0] => value[1]}) }
      end
    end
  end
end