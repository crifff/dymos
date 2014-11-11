require 'aws-sdk-core'

module Dymos
  class Client
    attr_reader :client

    def initialize(params={})
      config = Aws.config.merge params
      @client = Aws::DynamoDB::Client.new(config)
    end

    def command(name, params)
      @client.send name, params
    end

    def create_table(scheme)
      query = {}
      query[:table_name] = scheme[:name]
      query[:attribute_definitions] = scheme[:attributes].map { |k, v| {attribute_name: k.to_s, attribute_type: v.to_s} }
      query[:key_schema] = scheme[:keys].map { |k, v| {attribute_name: k.to_s, key_type: v.to_s} }
      query[:provisioned_throughput] = {read_capacity_units: scheme[:throughput][:read] || 10,
                                        write_capacity_units: scheme[:throughput][:write] || 5}

      query[:global_secondary_indexes] = scheme[:gsi].map do |gsi|
        index = {}
        index[:index_name] = gsi[:name]
        index[:key_schema] = gsi[:keys].map { |k, v| {attribute_name: k.to_s, key_type: v.to_s} }
        index[:projection] = {projection_type: gsi[:projection][:type].to_s}
        index[:projection][:non_key_attributes] = gsi[:projection][:attributes] if gsi.try(:[], :projection).try(:[], :attributes).present?
        index[:provisioned_throughput] = {read_capacity_units: gsi[:throughput][:read] || 10,
                                          write_capacity_units: gsi[:throughput][:write] || 5}
        index
      end if scheme.try(:[], :gsi)

      query[:local_secondary_indexes] = scheme[:lsi].map do |lsi|
        index = {}
        index[:index_name] = lsi[:name]
        index[:key_schema] = lsi[:keys].map { |k, v| {attribute_name: k.to_s, key_type: v.to_s} }
        index[:projection] = {projection_type: lsi[:projection][:type].to_s}
        index[:projection][:non_key_attributes] = lsi[:projection][:attributes] if lsi.try(:[], :projection).try(:[], :attributes).present?

        index
      end if scheme.try(:[], :lsi)

      self.command :create_table, query
    end
  end
end
