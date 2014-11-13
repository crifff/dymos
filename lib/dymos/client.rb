require 'aws-sdk-core'

module Dymos
  class Client
    attr_reader :client

    def initialize(params={})
      config = Aws.config.merge params
      @client ||= Aws::DynamoDB::Client.new(config)
    end

    def command(name, params)
      @client.send name, params
    end
  end
end
