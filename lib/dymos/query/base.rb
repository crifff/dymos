module Dymos
  module Query
    class Base
      def initialize
        @query={}
      end

      def command

      end

      def name(value)
        @query[:table_name] = value
        self
      end

      def build(value={})
        value = ::Dymos::Config.default[command.to_sym].merge value
        @query.merge value
      end
    end
  end
end