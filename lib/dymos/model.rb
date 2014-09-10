require 'aws-sdk-core'
require 'active_model'

module Dymos
  class Model
    include ActiveModel::Model
    include ActiveModel::Dirty
    include Dymos::Persistence
    extend Dymos::Command
    attr_accessor :metadata

    def initialize(params={})
      @attributes={}
      send :attributes=, params, true
      super
    end

    def self.field(attr, type, default: nil)
      @fields ||= {}
      @fields[attr]={
          type: type,
          default: default
      }
      define_attribute_methods attr
      define_method(attr) { read_attribute(attr) || default }
      define_method("#{attr}_type") { type }
      define_method("#{attr}?") { !read_attribute(attr).nil? }
      define_method("#{attr}=") { |value| write_attribute(attr, value) }
    end

    def self.table(name)
      define_singleton_method('table_name') { name }
      define_method('table_name') { name }
    end

    def attributes=(attributes = {}, initialize = false)
      if attributes
        attributes.each do |attr, value|
          write_attribute(attr, value, initialize)
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
      indexes = key_scheme
      keys={}
      keys[indexes.first[:attribute_name].to_sym] = key1
      keys[indexes.last[:attribute_name].to_sym] = key2 if indexes.size > 1
      self.get.key(keys).execute
    end

    def self.key_scheme
      @key_scheme ||= new.describe_table[:table][:key_schema]
    end

    def reload!
      reset_changes
    end

    def describe_table
      self.class.send(:describe).execute
    end

    def indexes
      scheme = self.class.key_scheme.map do |scheme|
         [scheme[:attribute_name], send(scheme[:attribute_name])]
      end
      scheme.to_h
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

    def write_attribute(name, value, initialize=false)
      self.send "#{name}_will_change!" unless (initialize or value == @attributes[name.to_sym])
      @attributes[name.to_sym] = value
    end

  end
end
