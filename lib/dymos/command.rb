module Dymos
  module Command
    class << self
      def find(key1, key2=nil)
        builder=Dymos::Query::GetItem.new.name(table_name)
        p keys
        #builder.key
      end

      def all
        builder=Dymos::Query::Query.new.name(table_name)
      end

      def describe
        builder=Dymos::Query::Describe.new.name(table_name)
      end
    end

    def save
      builder=Dymos::Query::PutItem.new.name(table_name)
    end

    def update
      builder=Dymos::Query::UpdateItem.new.name(table_name)
    end

    def delete
      builder=Dymos::Query::DeleteItem.new.name(table_name)
    end
  end
end