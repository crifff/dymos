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
    rescue => e
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
      send :updated_at=, Time.new.iso8601 if respond_to? :updated_at
      _execute
    end

    def _create_record()
      send :created_at=, Time.new.iso8601 if respond_to? :created_at
      send :updated_at=, Time.new.iso8601 if respond_to? :updated_at
      _execute
    end

    def _execute()
      result = self.class.put.item(attributes).execute
      changes_applied
      @new_record = false
      result
    end

  end
end
