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
      run_callbacks :save do
        _put
      end
    rescue => e
      false
    end

    def save!(*)
      run_callbacks :save do
        _put || raise(::Dymos::RecordNotSaved)
      end
    end

    def update(*)
      run_callbacks :save do
        _update
      end
    rescue => e
      false
    end

    def update!(*)
      run_callbacks :save do
        _update || raise(::Dymos::RecordNotSaved)
      end
    end

    def delete

      if persisted?
        builder = ::Dymos::Query::DeleteItem.new

        builder.name(self.table_name).key(indexes).return_values(:all_old)

        @query.each do |k, v|
          builder.send k, *v
        end if @query.present?
        @query={}

        query = builder.build
        @last_execute_query = {command: builder.command, query: query}
        ::Dymos::Client.new.command builder.command, query
      end
      @destroyed = true
      freeze
    end

    private

    def _put
      send :created_at=, Time.new.iso8601 if respond_to? :created_at if @new_record
      send :updated_at=, Time.new.iso8601 if respond_to? :updated_at
      builder = ::Dymos::Query::PutItem.new
      builder.name(self.table_name).item(attributes).return_values(:all_old)

      @query.each do |k, v|
        builder.send k, *v
      end if @query.present?
      @query={}

      _execute(builder)
    end

    def _update
      send :updated_at=, Time.new.iso8601 if respond_to? :updated_at
      builder = ::Dymos::Query::UpdateItem.new

      builder.name(self.table_name).key(indexes).return_values(:all_old)

      self.changes.each do |column, change|
        builder.put(column, change[1])
      end

      @query.each do |k, v|
        builder.send k, *v
      end if @query.present?
      @query={}

      _execute(builder)
    end

    #
    # def _update_record()
    #   send :updated_at=, Time.new.iso8601 if respond_to? :updated_at
    #   _execute
    # end
    #
    # def _create_record()
    #   send :created_at=, Time.new.iso8601 if respond_to? :created_at
    #   send :updated_at=, Time.new.iso8601 if respond_to? :updated_at
    #   _execute
    # end

    def _execute(builder)
      query = builder.build
      @last_execute_query = {command: builder.command, query: query}
      response = ::Dymos::Client.new.command builder.command, query
      fail raise(::Dymos::RecordNotSaved) if response.nil?
      changes_applied
      @new_record = false
      response.present?
    end

  end
end
