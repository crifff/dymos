describe Dymos::Query::PutItem do
  before :all do
    Aws.config[:region] = 'us-west-1'
    Aws.config[:endpoint] = 'http://localhost:4567'
    Aws.config[:access_key_id] = 'XXX'
    Aws.config[:secret_access_key] = 'XXX'

    client = Aws::DynamoDB::Client.new
    client.delete_table(table_name: 'test_put_item') if client.list_tables[:table_names].include?('test_put_item')
    client.create_table(
        table_name: 'test_put_item',
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
    client.put_item(table_name: 'test_put_item', item: {id: 'hoge', name: '太郎'})
    client.put_item(table_name: 'test_put_item', item: {id: 'fuga', category_id: 1})

    class TestItem < Dymos::Model
      table :test_put_item
      field :id, :string
    end
  end

  let(:client) { Aws::DynamoDB::Client.new }
  describe :put_item do
    describe "クエリ生成" do
      it "追加のみ" do
        query = TestItem.put.item(id: "foo", name: "John")
        expect(query.query).to eq({
                                      table_name: "test_put_item",
                                      item: {id: "foo", name: "John"},
                                      return_values: "ALL_OLD",
                                  })
      end

    end
    it "条件なしput_item実行 追加時はattributesがnilになる" do
      query = TestItem.put.item(id: "foo", name: "John")
      result = query.execute client
      expect(result).to eq(nil)
    end

    # it "条件ありput_item" do
    #   query = TestPutItem.put.item(id: "hoge", name: "次郎").expected(name: "== 太郎")
    #   expect(query.query).to eq({
    #                                 table_name: "test_put_item",
    #                                 item: {id: "hoge", name: "次郎"},
    #                                 :expected => {:name => {:value => "太郎", :comparison_operator => "EQ"}},
    #                                 return_values: "ALL_OLD",
    #                             })
    #
    #   query = TestPutItem.put.item(id: "hoge", name: "次郎").expected(category_id: "== 1")
    #   expect(query.query).to eq({
    #                                 table_name: "test_put_item",
    #                                 item: {id: "hoge", name: "次郎"},
    #                                 :expected => {:category_id => {:value => 1, :comparison_operator => "EQ"}},
    #                                 return_values: "ALL_OLD",
    #                             })
    #
    #   query = TestPutItem.put.item(id: "hoge", name: "次郎").expected(category_id: "between 0 2")
    #   expect(query.query).to eq({
    #                                 table_name: "test_put_item",
    #                                 item: {id: "hoge", name: "次郎"},
    #                                 :expected => {:category_id => {:attribute_value_list => [0, 2], :comparison_operator => "BETWEEN"}},
    #                                 return_values: "ALL_OLD",
    #                             })
    # end

    # it "条件ありput_item実行 成功すると古いデータを返す" do
    #   query = TestPutItem.put.item(id: "hoge", name: "次郎").expected(name: "== 太郎")
    #   result = query.execute client
    #   expect(result.attributes).to eq({id: "hoge", name: "太郎"})
    # end

    describe "条件指定" do
      describe :== do
        let(:query) { TestItem.put.item(id: "fuga", category_id: 1).expected(category_id: "== 1") }
        it :query do
          expect(query.query).to eq(table_name: "test_put_item",
                                    item: {id: "fuga", category_id: 1},
                                    expected: {:category_id => {:value => 1, :comparison_operator => "EQ"}},
                                    return_values: "ALL_OLD")
        end
        it :execute do
          result = query.execute client
          expect(result.attributes).to eq({id: "fuga", category_id: 1})
        end
        it :error do
          query = TestItem.put.item(id: "fuga", category_id: 1).expected(category_id: "== 2")
          expect(query.execute(client)).to eq(false)
        end
      end

      describe :> do
        let(:query) { TestItem.put.item(id: "fuga", category_id: 1).expected(category_id: "> 0") }
        it :query do
          expect(query.query).to eq(table_name: "test_put_item",
                                    item: {id: "fuga", category_id: 1},
                                    expected: {:category_id => {:value => 0, :comparison_operator => "GT"}},
                                    return_values: "ALL_OLD")
        end
        it :execute do
          result = query.execute client
          expect(result.attributes).to eq({id: "fuga", category_id: 1})
        end
        it :error do
          query = TestItem.put.item(id: "fuga", category_id: 1).expected(category_id: "> 2")
          expect(query.execute(client)).to eq(false)
        end
      end

      describe :>= do
        let(:query) { TestItem.put.item(id: "fuga", category_id: 1).expected(category_id: ">= 1") }
        it :query do
          expect(query.query).to eq(table_name: "test_put_item",
                                    item: {id: "fuga", category_id: 1},
                                    expected: {:category_id => {:value => 1, :comparison_operator => "GE"}},
                                    return_values: "ALL_OLD")
        end
        it :execute do
          result = query.execute client
          expect(result.attributes).to eq({id: "fuga", category_id: 1})
        end
        it :error do
          query = TestItem.put.item(id: "fuga", category_id: 1).expected(category_id: "> 2")
          expect(query.execute(client)).to eq(false)
        end
      end

      describe :< do
        let(:query) { TestItem.put.item(id: "fuga", category_id: 1).expected(category_id: "< 2") }
        it :query do
          expect(query.query).to eq(table_name: "test_put_item",
                                    item: {id: "fuga", category_id: 1},
                                    expected: {:category_id => {:value => 2, :comparison_operator => "LT"}},
                                    return_values: "ALL_OLD")
        end
        it :execute do
          result = query.execute client
          expect(result.attributes).to eq({id: "fuga", category_id: 1})
        end
        it :error do
          query = TestItem.put.item(id: "fuga", category_id: 1).expected(category_id: "< 0")
          expect(query.execute(client)).to eq(false)
        end
      end

      describe :<= do
        let(:query) { TestItem.put.item(id: "fuga", category_id: 1).expected(category_id: "<= 1") }
        it :query do
          expect(query.query).to eq(table_name: "test_put_item",
                                    item: {id: "fuga", category_id: 1},
                                    expected: {:category_id => {:value => 1, :comparison_operator => "LE"}},
                                    return_values: "ALL_OLD")
        end
        it :execute do
          result = query.execute client
          expect(result.attributes).to eq({id: "fuga", category_id: 1})
        end
        it :error do
          query = TestItem.put.item(id: "fuga", category_id: 1).expected(category_id: "<= 0")
          expect(query.execute(client)).to eq(false)
        end
      end

      describe :between do
        let(:query) { TestItem.put.item(id: "fuga", category_id: 1).expected(category_id: "between 1 2") }
        it :query do
          expect(query.query).to eq(table_name: "test_put_item",
                                    item: {id: "fuga", category_id: 1},
                                    expected: {:category_id => {:attribute_value_list => [1, 2], :comparison_operator => "BETWEEN"}},
                                    return_values: "ALL_OLD")
        end
        it :execute do
          result = query.execute client
          expect(result.attributes).to eq({id: "fuga", category_id: 1})
        end
        it :error do
          query = TestItem.put.item(id: "fuga", category_id: 1).expected(category_id: "between 2 3")
          expect(query.execute(client)).to eq(false)
        end
      end

      describe :contain do
        let(:query) { TestItem.put.item(id: "fuga", category_id: 1).expected(id: "contains uga") }
        it :query do
          expect(query.query).to eq(table_name: "test_put_item",
                                    item: {id: "fuga", category_id: 1},
                                    expected: {:id => {:value => "uga", :comparison_operator => "CONTAINS"}},
                                    return_values: "ALL_OLD")
        end
        it :execute do
          result = query.execute client
          expect(result.attributes).to eq({id: "fuga", category_id: 1})
        end
        it :error do
          query = TestItem.put.item(id: "fuga", category_id: 1).expected(id: "contains ppp")
          expect(query.execute(client)).to eq(false)
        end
      end

      describe :not_contain do
        let(:query) { TestItem.put.item(id: "fuga", category_id: 1).expected(id: "not_contains ppp") }
        it :query do
          expect(query.query).to eq(table_name: "test_put_item",
                                    item: {id: "fuga", category_id: 1},
                                    expected: {:id => {:value => "ppp", :comparison_operator => "NOT_CONTAINS"}},
                                    return_values: "ALL_OLD")
        end
        it :execute do
          result = query.execute client
          expect(result.attributes).to eq({id: "fuga", category_id: 1})
        end
        it :error do
          query = TestItem.put.item(id: "fuga", category_id: 1).expected(id: "not_contains uga")
          expect(query.execute(client)).to eq(false)
        end
      end

      describe :begins_with do
        let(:query) { TestItem.put.item(id: "fuga", category_id: 1).expected(id: "begins_with fug") }
        it :query do
          expect(query.query).to eq(table_name: "test_put_item",
                                    item: {id: "fuga", category_id: 1},
                                    expected: {:id => {:value => "fug", :comparison_operator => "BEGINS_WITH"}},
                                    return_values: "ALL_OLD")
        end
        it :execute do
          result = query.execute client
          expect(result.attributes).to eq({id: "fuga", category_id: 1})
        end
        it :error do
          query = TestItem.put.item(id: "fuga", category_id: 1).expected(id: "begins_with uga")
          expect(query.execute(client)).to eq(false)
        end
      end

      describe :is_null do
        let(:query) { TestItem.put.item(id: "fuga", category_id: 1).expected(bar: "is_null") }
        it :query do
          expect(query.query).to eq(table_name: "test_put_item",
                                    item: {id: "fuga", category_id: 1},
                                    expected: {:bar => {:comparison_operator => "NULL"}},
                                    return_values: "ALL_OLD")
        end
        it :execute do
          result = query.execute client
          expect(result.attributes).to eq({id: "fuga", category_id: 1})
        end
        it :error do
          query = TestItem.put.item(id: "fuga", category_id: 1).expected(id: "is_null")
          expect(query.execute(client)).to eq(false)
        end
      end

      describe :is_not_null do
        let(:query) { TestItem.put.item(id: "fuga", category_id: 1).expected(id: "is_not_null") }
        it :query do
          expect(query.query).to eq(table_name: "test_put_item",
                                    item: {id: "fuga", category_id: 1},
                                    expected: {:id => {:comparison_operator => "NOT_NULL"}},
                                    return_values: "ALL_OLD")
        end
        it :execute do
          result = query.execute client
          expect(result.attributes).to eq({id: "fuga", category_id: 1})
        end
        it :error do
          query = TestItem.put.item(id: "fuga", category_id: 1).expected(bar: "is_not_null")
          expect(query.execute(client)).to eq(false)
        end
      end
    end
    #
    # it :< do
    #   query = TestPutItem.put.item(id: "fuga", category_id: 1).expected(category_id: "< 2")
    #   result = query.execute client
    #   expect(result.attributes).to eq({id: "fuga", category_id: 1})
    # end
    # it :between do
    #   query = TestPutItem.put.item(id: "fuga", category_id: 1).expected(category_id: "between 1 2")
    #   result = query.execute client
    #   expect(result.attributes).to eq({id: "fuga", category_id: 1})
    # end
  end
end

