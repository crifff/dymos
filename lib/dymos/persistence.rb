module Dymos
  module Persistence
    attr_accessor :new_record

    def initialize(params={})
      @new_record = true
      @destroyed = false
    end

    def new_record?
      @new_record
    end

    def destroyed?
      @destroyed
    end

    def persisted?
      !(new_record? || destroyed?)
    end

    def save(*)
      create_or_update
    rescue
      false
    end

    def save!(*)
      create_or_update || raise(Dymos::RecordNotSaved)
    end

    def delete
      self.class.delete.key(indexes).execute if persisted?
      @destroyed = true
      freeze
    end

    private

    def create_or_update
      result = new_record? ? _create_record : _update_record
      result != false
    end

    def _update_record()
      _create_record
    end

    def _create_record()
      result = dynamo.put_item(
          table_name: table_name,
          item: attributes,
          return_values: "ALL_OLD"
      )
      changes_applied
      @new_record = false
      !result.error
    end

  end
end
