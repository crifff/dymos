describe Dymos::Query::Builder do
  before :all do
    Aws.config[:region] = 'us-west-1'
    Aws.config[:endpoint] = 'http://localhost:4567'
    Aws.config[:access_key_id] = 'XXX'
    Aws.config[:secret_access_key] = 'XXX'
  end

  describe :list_tables do
    let(:query) { Dymos::Query::Builder.new(:list_tables) }

    it "command" do
      expect(query.command).to eq(:list_tables)
    end

    it "execute" do
      client = Aws::DynamoDB::Client.new
      expect(query.execute(client).methods.include? :table_names).to eq(true)
    end
  end

  describe :put_item do
    before :all do
      client = Aws::DynamoDB::Client.new
      # client.delete_table(table_name: 'test_put_item') if client.list_tables[:table_names].include?('test_put_item')
      # client.create_table(
      #     table_name: 'test_put_item',
      #     attribute_definitions: [
      #         {attribute_name: 'id', attribute_type: 'S'}
      #     ],
      #     key_schema: [
      #         {attribute_name: 'id', key_type: 'HASH'}
      #     ],
      #     provisioned_throughput: {
      #         read_capacity_units: 1,
      #         write_capacity_units: 1,
      #     })
      # client.put_item(table_name: 'test_put_item', item: {id: 'hoge', name: '太郎'})
      # client.put_item(table_name: 'test_put_item', item: {id: 'fuga', name: '次郎'})
      # client.put_item(table_name: 'test_put_item', item: {id: 'piyo', name: '三郎'})
    end
    let(:client) { Aws::DynamoDB::Client.new }
    let(:query) { Dymos::Query::Builder.new(:put_item, "test_put_item") }

    it 'put' do
      # User.put.item(id:"hoge",name:"太郎").expected(id:'hoge')
      # query.query = {
      #     table_name: query.table_name,
      #     item: {
      #         id: "hoge",
      #         name: "太郎2",
      #     },
      #     expected: {
      #         id: Dymos::Query::Expect.new(:s).condition(:==, 'hoge').data,
      #         name: Dymos::Query::Expect.new(:s).condition(:==, '太郎2').data,
      #     },
      #     return_values: "ALL_OLD",
      # }
      # result = query.execute client
      # expect(result).to eq('hoge')
    end

  end
end

