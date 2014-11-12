describe Dymos::Query::PutItem do
  describe 'build query', order: :defined do
    let(:builder) { Dymos::Query::PutItem.new }
    let(:table) { 'test_put_item_table' }

    it do
      @client.delete_table(table_name: table) if @client.list_tables[:table_names].include?(table)
      query=Dymos::Query::CreateTable.new.name(table).attributes(id: 'S').keys(id: 'HASH').build
      @client.create_table(query)
      @client.put_item(table_name: table, item: {id: 'hoge', param1: 101, param2: 201, param3: "hoge", param4: [1, 0, 1]})
      @client.put_item(table_name: table, item: {id: 'fuga', param1: 102, param2: 202, param3: "fuga", param4: [1, 0, 2]})
      @client.put_item(table_name: table, item: {id: 'piyo', param1: 103, param2: 203, param3: "piyo", param4: [1, 0, 3]})
    end

    it :create do
      data={id: 'poyo', param1: 104, param2: 204, param3: "poyo", param4: [1, 0, 4]}
      builder.name(table).item(data).return_values(:ALL_OLD)
      result = @client.put_item builder.build
      expect(result.error).to eq(nil)
      expect(result.attributes).to eq(nil)

      res = @client.get_item(table_name: table, key: {id: 'poyo'})
      expect(res.item.to_hash).to eq(data.deep_stringify_keys)
    end

    it 'failed expect' do
      data={id: 'poyo', param1: 104+1, param2: 204, param3: "poyo", param4: [1, 0, 4]<<'x'}
      builder.name(table).item(data).return_values(:ALL_OLD).expected(param1: 0)
      expect { @client.put_item(builder.build) }.to raise_error(Aws::DynamoDB::Errors::ConditionalCheckFailedException)
    end

    it :expected do
      data={id: 'poyo', param1: 104+1, param2: 204, param3: "poyo", param4: [1, 0, 4]<<'x'}
      builder.name(table).item(data).return_values(:ALL_OLD).expected(param1: 104, param4: [1, 0, 4])
      result = @client.put_item(builder.build)
      expect(result.error).to eq(nil)
      expect(result.attributes["param1"]).to eq(104)


      res = @client.get_item(table_name: table, key: {id: 'poyo'})
      expect(res.item["param1"]).to eq(105)
    end

    it :between do
      data={id: 'poyo', param1: 105+1, param2: 204, param3: "poyo", param4: [1, 0, 4, 'x']}
      builder.name(table).item(data).return_values(:ALL_OLD).expected([[:param1, :BETWEEN, [104, 106]]])

      result = @client.put_item(builder.build)
      expect(result.error).to eq(nil)
      expect(result.attributes["param1"]).to eq(105)
    end

    it :in do
      data={id: 'poyo', param1: 106+1, param2: 204, param3: "poyo", param4: [1, 0, 4, 'x']}
      builder.name(table).item(data).return_values(:ALL_OLD).add_expected(:param1, :IN, [101, 103, 106])

      result = @client.put_item(builder.build)
      expect(result.error).to eq(nil)
      expect(result.attributes["param1"]).to eq(106)
    end
  end
end

