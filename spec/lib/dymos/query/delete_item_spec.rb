describe Dymos::Query::DeleteItem do
  describe 'build query', order: :defined do
    let(:builder) { Dymos::Query::DeleteItem.new }
    let(:table) { 'test_delete_item_table' }

    it do
      @client.delete_table(table_name: table) if @client.list_tables[:table_names].include?(table)
      query=Dymos::Query::CreateTable.new.name(table).attributes(id: 'S').keys(id: 'HASH').build
      @client.create_table(query)
      @client.put_item(table_name: table, item: {id: 'hoge', param1: 101, param2: 201, param3: "hoge", param4: [1, 0, 1]})
      @client.put_item(table_name: table, item: {id: 'fuga', param1: 102, param2: 202, param3: "fuga", param4: [1, 0, 2]})
      @client.put_item(table_name: table, item: {id: 'piyo', param1: 103, param2: 203, param3: "piyo", param4: [1, 0, 3]})
    end

    it :key do
      builder.name(table).key(id: 'hoge').return_values(:ALL_OLD)
      result = @client.delete_item(builder.build)
      expect(result[:attributes]["id"]).to eq("hoge")
    end

    it :expected do

      builder.name(table).key(id: 'fuga').return_values(:ALL_OLD).expected(param1: 0)
      expect { @client.delete_item(builder.build) }.to raise_error(Aws::DynamoDB::Errors::ConditionalCheckFailedException)

      builder.name(table).key(id: 'fuga').return_values(:ALL_OLD).expected(param1: 102)
      result = @client.delete_item(builder.build)
      expect(result[:attributes]["id"]).to eq("fuga")
    end

  end
end

