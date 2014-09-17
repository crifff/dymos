require "dymos/query/attribute"
require "dymos/query/expect"
require "dymos/query/builder"
require "dymos/query/put_item"
require "dymos/query/update_item"
require "dymos/query/delete_item"
require "dymos/query/get_item"
require "dymos/query/describe"
require "dymos/query/scan"
require "dymos/query/query"
require "dymos/attribute"
require "dymos/command"
require "dymos/persistence"
require "dymos/model"
require "dymos/version"

module Dymos
end

module Aws
  module DynamoDB
    class AttributeValue
      class Marshaler
        def format(obj)
          case obj
            when String then { s: obj }
            when Time then { s: obj.iso8601 }
            when Numeric then { n: obj.to_s }
            when StringIO, IO then { b: obj.read }
            when Set then format_set(obj)
            else
              msg = "unsupported type, expected Set, String, Numeric, or "
              msg << "IO object, got #{obj.class.name}"
              raise ArgumentError, msg
          end
        end
      end
    end
  end
end