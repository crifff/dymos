require 'active_support/all'

require "dymos/config"
require "dymos/error"
require "dymos/query/parameter/filter_expression"
require "dymos/query/base"
require "dymos/query/put_item"
require "dymos/query/update_item"
require "dymos/query/delete_item"
require "dymos/query/get_item"
require "dymos/query/describe"
require "dymos/query/scan"
require "dymos/query/query"
require "dymos/query/create_table"
require "dymos/attribute"
require "dymos/persistence"
require "dymos/model"
require "dymos/client"
require "dymos/version"

module Dymos
  def self.model_query_methods
    @model_query_methods ||= ::Dymos::Query::Query.instance_methods(false)+
      ::Dymos::Query::GetItem.instance_methods(false)+
      ::Dymos::Query::Scan.instance_methods(false)+
      ::Dymos::Query::Parameter::FilterExpression.instance_methods(false)

  end

  def self.model_update_query_methods
    @model_update_query_methods ||= ::Dymos::Query::UpdateItem.instance_methods(false)+
      ::Dymos::Query::PutItem.instance_methods(false)+
      ::Dymos::Query::DeleteItem.instance_methods(false)
  end
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