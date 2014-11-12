require 'aws-sdk-core'

module Dymos
  class Config

    @default={
      get_item: {},
      create_table: {},
      query: {},
      scan: {},
      put_item: {},
      update_item: {},
      describe_table: {},
      delete_item: {},
      batch_get_item: {},
      batch_write_item: {},
      delete_table: {},
      list_tables: {},
    }

    class << self
      attr_reader :default

      def default=(config)
        if Hash === config
          @default = config
        else
          raise ArgumentError, 'configuration object must be a hash'
        end
      end
    end

  end
end
