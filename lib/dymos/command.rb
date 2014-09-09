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

    def describe
      Dymos::Query::Describe.new(:describe_table, table_name, class_name)
    end

    def scan
      Dymos::Query::Scan.new(:scan, table_name, class_name)
    end
  end
end