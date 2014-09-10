describe Dymos::Query::GetItem do
  before :all do
    Aws.config[:region] = 'us-west-1'
    Aws.config[:endpoint] = 'http://localhost:4567'
    Aws.config[:access_key_id] = 'XXX'
    Aws.config[:secret_access_key] = 'XXX'

    client = Aws::DynamoDB::Client.new
    client.delete_table(table_name: 'test_get_item') if client.list_tables[:table_names].include?('test_get_item')
    client.create_table(
        table_name: 'test_get_item',
        attribute_definitions: [
            {attribute_name: 'id', attribute_type: 'S'},
            {attribute_name: 'category_id', attribute_type: 'N'},
        ],
        key_schema: [
            {attribute_name: 'id', key_type: 'HASH'},
            {attribute_name: 'category_id', key_type: 'RANGE'}
        ],
        provisioned_throughput: {
            read_capacity_units: 1,
            write_capacity_units: 1,
        })
    client.put_item(table_name: 'test_get_item', item: {id: 'hoge', category_id: 0, name: '太郎'})
    client.put_item(table_name: 'test_get_item', item: {id: 'hoge', category_id: 1})

    class TestItem < Dymos::Model
      table :test_get_item
      field :id, :string
    end
  end

  let(:client) { Aws::DynamoDB::Client.new }
  describe :put_item do
    describe "クエリ生成" do
      it "追加のみ" do
        query = TestItem.get.key(id: 'hoge', category_id: 1)
        expect(query.query).to eq({
                                      table_name: "test_get_item",
                                      key: {id: "hoge", category_id: 1},
                                      consistent_read: true,
                                  })
        # p client.scan(table_name: "test_get_item")
        res = query.execute client
        expect(res.id).to eq('hoge')
        expect(res.metadata).to eq(consumed_capacity: nil)

        # expect(res).to eq({})
        # p client.scan(table_name:"test_get_item")
      end

    end
  end
end

