module Dymos
  module Query
    class CreateTable
      def initialize
        @query={}
      end

      def name(value)
        @query[:table_name] = value
        self
      end

      def attributes(value)
        @query[:attribute_definitions] = _attributes(value)
        self
      end

      private def _attributes(value)
        value.map { |k, v|
          {attribute_name: k.to_s, attribute_type: v.to_s}
        }
      end

      def keys(value)
        @query[:key_schema]=_keys(value)
        self
      end

      private def _keys(value)
        value.map { |k, v|
          {attribute_name: k.to_s, key_type: v.to_s}
        }
      end

      def throughput(value)
        @query[:provisioned_throughput] = _throughput(value)
        self
      end

      private def _throughput(value)
        {
          read_capacity_units: value[:read],
          write_capacity_units: value[:write]
        }
      end

      def gsi(value)
        @query[:global_secondary_indexes] = value.map { |i|
          index = _index(i)
          index[:provisioned_throughput] = _throughput(i[:throughput])
          index
        }
        self
      end

      def lsi(value)
        @query[:local_secondary_indexes] = value.map do |i|
          _index(i)
        end
        self
      end

      private def _index(i)
        index = {}
        index[:index_name] = i[:name]
        index[:key_schema] = _keys(i[:keys])
        index[:projection]= _projection_type(i)
        index[:projection][:non_key_attributes] = i[:projection][:attributes] if i.try(:[], :projection).try(:[], :attributes).present?
        index
      end

      private def _projection_type(i)
        {projection_type: (i.try(:[], :projection).try(:[], :type) || 'ALL').to_s}
      end

      def build(value={})
        @query[:provisioned_throughput] = _throughput(read:10,write:5) if @query[:provisioned_throughput].blank?
        @query.merge value
      end

    end
  end
end