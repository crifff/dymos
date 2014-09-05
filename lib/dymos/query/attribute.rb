module Dymos
  module Query
    class Attribute
      def initialize(value)
        value =value.to_i if /^[0-9]+$/ =~ value
        @value = value
      end

      def data
        @value
      end
    end
  end
end