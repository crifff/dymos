describe Dymos::Query::UpdateItem do
  before do
    Dymos::Config.default[:update_item]={
      return_values: 'ALL_NEW'
    }
  end

  describe 'build query', order: :defined do
    let(:builder) { Dymos::Query::UpdateItem.new }
    table='test_update_item_table'

    before :all do
      @client.delete_table(table_name: table) if @client.list_tables[:table_names].include?(table)
      query=Dymos::Query::CreateTable.new.name(table).attributes(id: 'S').keys(id: 'HASH').build
      @client.create_table(query)
      @client.put_item(table_name: table, item: {id: 'hoge', param1: 101, param2: 201, param3: "hoge", param4: [1, 0, 1]})
      @client.put_item(table_name: table, item: {id: 'fuga', param1: 102, param2: 202, param3: "fuga", param4: [1, 0, 2]})
      @client.put_item(table_name: table, item: {id: 'piyo', param1: 103, param2: 203, param3: "piyo", param4: [1, 0, 3]})
    end
    it :attribute_updates do
      builder.name(table).key(id: 'hoge').attribute_updates([:param1, :add, 1000], [:param2, :put, 1201]).return_values(:all_new)
      result = @client.update_item(builder.build)
      expect(result.error).to eq(nil)
      expect(result.attributes["param1"]).to eq(1101)
      expect(result.attributes["param2"]).to eq(1201)
    end
    it 'put, add' do
      builder.name(table).key(id: 'hoge').add(:param1, 1).put(:param2, 1202)
      result = @client.update_item(builder.build)
      expect(result.error).to eq(nil)
      expect(result.attributes["param1"]).to eq(1102)
      expect(result.attributes["param2"]).to eq(1202)
    end
    it 'expected' do
      builder.name(table).key(id: 'hoge').add(:param1, 1).put(:param2, 1203).expected(param3: "hoge", param4: [1, 0, 1])
      result = @client.update_item(builder.build)
      expect(result.error).to eq(nil)
      expect(result.attributes["param1"]).to eq(1103)
      expect(result.attributes["param2"]).to eq(1203)
    end
  end
end

