describe Dymos::Query::DeleteItem do
  before :all do
    Aws.config[:region] = 'us-west-1'
    Aws.config[:endpoint] = 'http://localhost:4567'
    Aws.config[:access_key_id] = 'XXX'
    Aws.config[:secret_access_key] = 'XXX'

    client = Aws::DynamoDB::Client.new
    client.delete_table(table_name: 'test_delete_item') if client.list_tables[:table_names].include?('test_delete_item')
    client.create_table(
        table_name: 'test_delete_item',
        attribute_definitions: [
            {attribute_name: 'id', attribute_type: 'S'},
        ],
        key_schema: [
            {attribute_name: 'id', key_type: 'HASH'}
        ],
        provisioned_throughput: {
            read_capacity_units: 1,
            write_capacity_units: 1,
        })
    client.put_item(table_name: 'test_delete_item', item: {id: 'hoge', name: '太郎'})
    client.put_item(table_name: 'test_delete_item', item: {id: 'fuga', count: 0})
    client.put_item(table_name: 'test_delete_item', item: {id: 'poyo', name: '可奈'})
    client.put_item(table_name: 'test_delete_item', item: {id: 'puyo', name: '志保'})
    client.put_item(table_name: 'test_delete_item', item: {id: 'piyo', name: '杏奈', count: 10})
    client.put_item(table_name: 'test_delete_item', item: {id: 'puni', name: '美奈子', count: 10, text: "hoge"})

    class TestItem < Dymos::Model
      table :test_delete_item
      field :id, :string
      field :name, :string
      field :count, :string
    end
  end

  let(:client) { Aws::DynamoDB::Client.new }
  describe :put_item do
    describe "クエリ生成" do
      let(:query) { TestItem.delete.key(id: "hoge") }
      it :query do
        expect(query.query).to eq({
                                      table_name: "test_delete_item",
                                      key: {id: "hoge"},
                                      return_values: "ALL_OLD",
                                  })
      end
      it "成功すると削除したアイテムを返す" do
        res = query.execute client
        expect(res.id).to eq("hoge")
      end

      describe "既存のアイテムを削除" do
        describe "return_values :ALL_OLD" do
          it "条件なし" do
            query = TestItem.delete.key(id: "poyo")
            res = query.execute client
            expect(res.id).to eq("poyo")
            expect(TestItem.get.key(id: "poyo").execute).to eq(nil)
          end

          it "条件付き" do
            query = TestItem.delete.key(id: "fuga").expected(count: "== 0")
            res = query.execute
            expect(res.id).to eq("fuga")
            expect(TestItem.get.key(id: "fuga").execute).to eq(nil)
          end
          it "条件付き2" do
            query = TestItem.delete.key(id: "puyo").expected(count: 'is_null')
            res = query.execute
            expect(res.id).to eq("puyo")
            expect(TestItem.get.key(id: "puyo").execute).to eq(nil)
          end
          it "複数条件条件付き" do
            query = TestItem.delete.key(id: "puni").expected(count: '== 10', text: '== hoge')
            res = query.execute
            expect(res.id).to eq("puni")
            expect(TestItem.get.key(id: "puni").execute).to eq(nil)
          end
          it "条件付き失敗" do
            query = TestItem.delete.key(id: "piyo").expected(count: "== 1")
            res = query.execute
            expect(res).to eq(false)
          end
        end
      end
    end
  end
end

