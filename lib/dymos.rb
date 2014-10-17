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

#Timeオブジェクト扱いたいのでアラウンドエイリアスで先に捕まえる
module Aws
  module DynamoDB
    class AttributeValue
      class Marshaler
        alias :orig_format :format
        def format(obj)
          case obj
            when Time then { s: obj.iso8601 }
            else
              orig_format obj
          end
        end
      end
    end
  end
end