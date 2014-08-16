require 'aws-sdk-core'

module Dymos
  class Base

    def table_name
      class_name
    end

    def class_name
      self.class.name
    end

    def attribute_types
      raise 'please override me!'
    end

    def attributes=(values)
      values.each do |k, v|
        type = attribute_types[k.to_sym]
        instance_variable_set("@#{k}", v.send(type))
      end
    end

    def attributes
      attrs = {}
      attribute_types.keys.each do |name|
        attrs[name] = instance_variable_get "@#{name}"
      end
      attrs
    end

    def dynamo
      Aws.config[:region] = 'us-west-1'
      Aws.config[:endpoint] = 'http://localhost:8000'
      Aws.config[:access_key_id] = 'XXX'
      Aws.config[:secret_access_key] = 'XXX'
      @dynamo ||= Aws::DynamoDB::Client.new()
    end

    def all
      models = dynamo.scan({table_name: table_name})
      models[:items].map! { |data|
        model = Object.const_get(class_name.capitalize).new
        model.attributes=data
        model
      }
    end

    def find(key, consistent=true)
      res = dynamo.get_item(
          table_name: table_name,
          key: {
              name: {s: key}
          },
          attributes_to_get: attribute_types.keys,
          consistent_read: consistent,
          return_consumed_capacity: 'TOTAL'
      )
      self.attributes = res.item
      self
    end

    def save
      items = {}
      attribute_types.each do |k, v|
        value = instance_variable_get("@#{k}")
        if value != nil
          items[k] ={
              v.to_sym => value.to_s
          }
        end
      end
      dynamo.put_item(
          table_name: table_name,
          item: items
      )
    end
  end
end