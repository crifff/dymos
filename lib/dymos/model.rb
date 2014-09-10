require 'aws-sdk-core'
require 'active_model'

module Dymos
  class Model
    include ActiveModel::Model
    extend Dymos::Command
    attr_accessor :metadata

    def initialize(params={})
      @attributes = {}
      super
    end

    def self.field(attr, type, default: nil)
      @fields ||= {}
      @fields[attr]={
          type: type,
          default: default
      }

      define_method(attr) { read_attribute(attr) || default }
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
      self.scan.execute
    end

    def self.find(key1, key2=nil)
      indexes = new.global_indexes
      keys={}
      keys[indexes.first[:attribute_name].to_sym] = key1
      keys[indexes.last[:attribute_name].to_sym] = key2 if indexes.size > 1
      self.get.key(keys).execute
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
