describe Dymos::Query::UpdateItem do
  before :all do
    Aws.config[:region] = 'us-west-1'
    Aws.config[:endpoint] = 'http://localhost:4567'
    Aws.config[:access_key_id] = 'XXX'
    Aws.config[:secret_access_key] = 'XXX'

    client = Aws::DynamoDB::Client.new
    client.delete_table(table_name: 'test_update_item') if client.list_tables[:table_names].include?('test_update_item')
    client.create_table(
        table_name: 'test_update_item',
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
    client.put_item(table_name: 'test_update_item', item: {id: 'hoge', name: '太郎'})
    client.put_item(table_name: 'test_update_item', item: {id: 'fuga', count: 0})
    client.put_item(table_name: 'test_update_item', item: {id: 'poyo', name: '可奈'})
    client.put_item(table_name: 'test_update_item', item: {id: 'piyo', name: '杏奈', count: 10})

    class TestItem < Dymos::Model
      table :test_update_item
      field :id, :string
      field :name, :string
      field :count, :string
    end
  end

  let(:client) { Aws::DynamoDB::Client.new }
  describe :put_item do
    describe "クエリ生成" do
      describe "新しいアイテムを追加" do
        let(:query) { TestItem.update.key(id: "foo").attribute_updates({name: "Sam"}, 'PUT') }
        it :query do
          expect(query.query).to eq({
                                        table_name: "test_update_item",
                                        key: {id: "foo"},
                                        attribute_updates: {name: {value: "Sam", action: "PUT"}},
                                        return_values: "ALL_NEW",
                                    })
        end
        it "成功すると新しいアイテムを返す" do
          res = query.execute client
          expect(res.id).to eq("foo")
        end
      end

      describe "既存のアイテムを更新" do
        describe "return_values :ALL_OLD" do
          it "更新した場合は更新前のアイテムを返す" do
            query = TestItem.update.key(id: "hoge").attribute_updates({name: "次郎"}, 'PUT').return_values(:ALL_OLD)
            res = query.execute client
            expect(res.name).to eq("太郎")
          end
          it "追加した場合はnilを返す" do
            query = TestItem.update.key(id: "bar").attribute_updates({name: "Sam"}, 'PUT').return_values(:ALL_OLD)
            res = query.execute client
            expect(res).to eq(nil)
          end
        end
        it "アイテムに加算する" do
          query = TestItem.update.key(id: "fuga").attribute_updates({count: 1}, 'add')
          res = query.execute client
          expect(res.count).to eq(1)
        end

        describe "条件付き更新" do
          describe :== do
            let(:query) { TestItem.update.key(id: "poyo").attribute_updates({name: "志保"}, 'PUT').expected(name: "== 可奈") }

            it :query do
              expect(query.query).to eq({
                                            table_name: "test_update_item",
                                            key: {id: "poyo"},
                                            attribute_updates: {name: {value: "志保", action: "PUT"}},
                                            expected: ({name: {value: "可奈", comparison_operator: "EQ"}}),
                                            return_values: "ALL_NEW",
                                        })
            end
            it "成功すると新しいアイテムを返す" do
              res = query.execute client
              expect(res.name).to eq("志保")
            end
          end
          describe :between do
            let(:query) { TestItem.update.key(id: "piyo").attribute_updates({name: "百合子"}, 'PUT').expected(count: "between 9 12") }

            it :query do
              expect(query.query).to eq({
                                            table_name: "test_update_item",
                                            key: {id: "piyo"},
                                            attribute_updates: {name: {value: "百合子", action: "PUT"}},
                                            expected: ({count: {attribute_value_list: [9, 12], comparison_operator: "BETWEEN"}}),
                                            return_values: "ALL_NEW",
                                        })
            end
            it "成功すると新しいアイテムを返す" do
              res = query.execute client
              expect(res.name).to eq("百合子")
            end
          end
        end
      end
    end
  end
end

