require 'aws-sdk-core'
require 'active_model'

module Dymos
  class Model
    include ActiveModel::Model
    extend Dymos::Command

    def initialize(params={})
      @attributes = {}
      super
    end

    def self.field(attr, type = :string)
      define_method(attr) { read_attribute(attr) }
      define_method("#{attr}_type") { type }
      define_method("#{attr}?") { !read_attribute(attr).nil? }
      define_method("#{attr}=") { |value| write_attribute(attr, value) }
    end

    def self.table(name)
      define_singleton_method('table_name') { name }
      define_method('table_name') { name }
    end

    def attributes=(attributes = {})
      if attributes
        attributes.each do |attr, value|
          write_attribute(attr, value)
        end
      end
    end

    def attributes
      attrs = {}
      @attributes.keys.each do |name|
        attrs[name] = read_attribute(name)
      end
      attrs
    end

    def self.all
      klass = new
      result = klass.dynamo.scan({table_name: klass.table_name})
      result.data[:items].map! { |data|
        model = Object.const_get(klass.class_name).new
        model.attributes=data
        model
      }
    end

    def self.find(key1, key2=nil, consistent_read: true)
      klass = new
      indexes = klass.global_indexes
      keys={}
      keys[indexes.first[:attribute_name]] = key1
      keys[indexes.last[:attribute_name]] = key2 if indexes.size > 1

      res = klass.dynamo.get_item(
          table_name: klass.table_name,
          key:  keys,
         # attributes_to_get: klass.attributes.keys,
          consistent_read: consistent_read,
          return_consumed_capacity: 'TOTAL'
      )
      klass.attributes = res.data.item
      klass
    end

    def save
      items = {}
      attributes.each do |k, v|
        if v != nil
          items[k] =v
        end
      end
      result = dynamo.put_item(
          table_name: table_name,
          item: items,
          return_values: "ALL_OLD"
      )
      !result.error
    end

    def describe_table
      @scheme ||= dynamo.describe_table(table_name: table_name)
    end

    def global_indexes
      describe_table.data[:table][:key_schema]
    end

    def dynamo
      @client ||= Aws::DynamoDB::Client.new
    end

    # @return [String]
    def self.class_name
      self.name
    end

    # @return [String]
    def class_name
      self.class.name
    end

    private
    def read_attribute(name)
      @attributes[name.to_sym]
    end

    def write_attribute(name, value)
      @attributes[name.to_sym] = value
    end

  end
end
