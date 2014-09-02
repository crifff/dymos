module Dymos
  module Command
    def put
      ::Dymos::Query::PutItem.new(:put_item, table_name)
    end

    def update

    end

    def scan

    end

    def describe

    end
  end
end