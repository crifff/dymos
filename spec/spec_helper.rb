require 'coveralls'
Coveralls.wear!

require 'rubygems'
require 'bundler/setup'
require 'timecop'
require 'dymos'

I18n.enforce_available_locales = false


RSpec.configure do |config|
  config.before do
    Aws.config[:region] = 'us-west-1'
    Aws.config[:endpoint] = 'http://localhost:4567'
    Aws.config[:access_key_id] = 'XXX'
    Aws.config[:secret_access_key] = 'XXX'
    @client=Aws::DynamoDB::Client.new

    list_tables = @client.list_tables.table_names
    %w(ProductCatalog Forum Thread Reply).each do |name|
      @client.delete_table(table_name: name) if list_tables.include? name
    end
    @client.create_table(table_name: 'ProductCatalog', attribute_definitions: [{attribute_name: 'Id', attribute_type: 'N'}], key_schema: [{attribute_name: 'Id', key_type: 'HASH'}], provisioned_throughput: {read_capacity_units: 10, write_capacity_units: 5})
    @client.create_table(table_name: 'Forum', attribute_definitions: [{attribute_name: 'Name', attribute_type: 'S'}], key_schema: [{attribute_name: 'Name', key_type: 'HASH'}], provisioned_throughput: {read_capacity_units: 10, write_capacity_units: 5})
    @client.create_table(table_name: 'Thread', attribute_definitions: [{attribute_name: 'ForumName', attribute_type: 'S'}, {attribute_name: 'Subject', attribute_type: 'S'}], key_schema: [{attribute_name: 'ForumName', key_type: 'HASH'}, {attribute_name: 'Subject', key_type: 'RANGE'}], provisioned_throughput: {read_capacity_units: 10, write_capacity_units: 5})
    @client.create_table(table_name: 'Reply', attribute_definitions: [{attribute_name: 'Id', attribute_type: 'S'}, {attribute_name: 'ReplyDateTime', attribute_type: 'S'}, {attribute_name: 'PostedBy', attribute_type: 'S'}], key_schema: [{attribute_name: 'Id', key_type: 'HASH'}, {attribute_name: 'ReplyDateTime', key_type: 'RANGE'}], provisioned_throughput: {read_capacity_units: 10, write_capacity_units: 5}, local_secondary_indexes: [{index_name: 'PostedByIndex', key_schema: [{attribute_name: 'Id', key_type: 'HASH'}, {attribute_name: 'PostedBy', key_type: 'RANGE'}], projection: {projection_type: 'KEYS_ONLY'}}])
    YAML.load_file('spec/lib/dymos/data.yml').each do |table_name,data|
      data.each do |datum|
        @client.put_item(table_name: table_name, item:datum)
      end
    end

  end
end