module Dymos
  module Command

    # @return [PutItem]
    def put
      Dymos::Query::PutItem.new(:put_item, table_name, class_name)
    end

    # @return [UpdateItem]
    def update
      Dymos::Query::UpdateItem.new(:update_item, table_name, class_name)
    end

    # @return [GetItem]
    def get
      Dymos::Query::GetItem.new(:get_item, table_name, class_name)
    end

    # @return [Query]
    def query
      Dymos::Query::Query.new(:query, table_name, class_name)
    end

    def scan

    end

    def describe

    end
  end
end