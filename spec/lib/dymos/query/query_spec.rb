describe Dymos::Query::Query do
  before :all do
    Aws.config[:region] = 'us-west-1'
    Aws.config[:endpoint] = 'http://localhost:4567'
    Aws.config[:access_key_id] = 'XXX'
    Aws.config[:secret_access_key] = 'XXX'

    client = Aws::DynamoDB::Client.new
    client.delete_table(table_name: 'test_query_item') if client.list_tables[:table_names].include?('test_query_item')
    client.create_table(
        table_name: 'test_query_item',
        attribute_definitions: [
            {attribute_name: 'id', attribute_type: 'S'},
            {attribute_name: 'category_id', attribute_type: 'N'},
            {attribute_name: 'other_id', attribute_type: 'N'},
        ],
        key_schema: [
            {attribute_name: 'id', key_type: 'HASH'},
            {attribute_name: 'category_id', key_type: 'RANGE'}
        ],
        global_secondary_indexes: [
            {
                index_name: "index_other_id",
                key_schema: [
                    {attribute_name: "id", key_type: "HASH"},
                    {attribute_name: "other_id", key_type: "RANGE"},
                ],
                projection: {
                    projection_type: "ALL",
                },
                provisioned_throughput: {
                    read_capacity_units: 1,
                    write_capacity_units: 1,
                },
            },
        ],
        provisioned_throughput: {
            read_capacity_units: 1,
            write_capacity_units: 1,
        })
    client.put_item(table_name: 'test_query_item', item: {id: 'hoge', category_id: 0, other_id: 1})
    client.put_item(table_name: 'test_query_item', item: {id: 'hoge', category_id: 1, other_id: 2})
    client.put_item(table_name: 'test_query_item', item: {id: 'hoge', category_id: 2, other_id: 3})
    client.put_item(table_name: 'test_query_item', item: {id: 'hoge', category_id: 3, other_id: 4})
    client.put_item(table_name: 'test_query_item', item: {id: 'hoge', category_id: 4, other_id: 5})
    client.put_item(table_name: 'test_query_item', item: {id: 'hoge', category_id: 5, other_id: 6})

    class TestItem < Dymos::Model
      table :test_query_item
      field :id, :string
    end
  end

  let(:client) { Aws::DynamoDB::Client.new }
  describe :put_item do
    describe "クエリ生成" do
      describe "グローバルセカンダリインデックスを利用した検索" do
        let(:query) {
          TestItem.query.index_name(:index_other_id).key_conditions(
              id: "== hoge",
              other_id: "between 1 3"
          )
        }
        it :query do
          expect(query.query).to eq(
                                     table_name: 'test_query_item',
                                     index_name: 'index_other_id',
                                     key_conditions: {
                                         id: {
                                             attribute_value_list: ["hoge"],
                                             comparison_operator: "EQ"
                                         },
                                         other_id: {
                                             attribute_value_list: [1, 3],
                                             comparison_operator: "BETWEEN"
                                         }},
                                     consistent_read: false,
                                 )
        end
        it :execute do
          res = query.execute client
          expect(res.size).to eq(3)
          expect(res.first.metadata).to eq(count: 3, scanned_count: 3, last_evaluated_key: nil, consumed_capacity: nil)
        end


      end
    end
  end
end

