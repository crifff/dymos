module Dymos
  module Query
    class Builder
      def self.to_model(class_name, res)
        if class_name.present?
          if res.data.respond_to? :items # scan, query
            metadata = extract(res, :items)
            res.data[:items].map do |datum|
              obj = Object.const_get(class_name).new(datum)
              obj.metadata = metadata
              obj.new_record = false
              obj
            end
          elsif res.data.respond_to? :attributes # put_item, update_item
            return nil if res.attributes.nil?
            obj = Object.const_get(class_name).new(res.attributes)
            obj.metadata = extract(res, :attributes)
            obj
          elsif res.respond_to? :data
            if res.data.respond_to? :item # get_item, delete_item
              return nil if res.data.item.nil?
              obj = Object.const_get(class_name).new(res.data.item)
              obj.metadata = extract(res, :item)
              obj.new_record = false
              obj
            else
              res.data.to_hash # describe
            end
          end
        else
          res.data.to_hash #list_tables
        end

      end

      def self.extract(res, ignore_key)
        keys = res.data.members.reject { |a| a == ignore_key }
        keys.map { |k| [k, res.data[k]] }.to_h
      end
    end
  end
end