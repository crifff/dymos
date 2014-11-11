describe Dymos::Client do
  before do
    Aws.config[:region] = 'us-west-1'
    Aws.config[:endpoint] = 'http://localhost:4567'
    Aws.config[:access_key_id] = 'XXX'
    Aws.config[:secret_access_key] = 'XXX'
  end

  it 'dynamodbに接続可能な設定がなされていればクラスを生成' do
    client = Dymos::Client.new
    expect(client.client.class).to eq(Aws::DynamoDB::Client)
  end

  describe :command do
    let (:client) { Dymos::Client.new }
    let (:aws_client) { client.client }
    it :create_table do
      aws_client.delete_table(table_name: 'test_create_table') if aws_client.list_tables[:table_names].include?('test_create_table')

      client.create_table(
        name: 'test_create_table',
        attributes: {id1: 'S', id2: 'S', id3: 'N'},
        keys: {id1: 'HASH', id2: 'RANGE'},
        throughput: {read: 20, write: 20},
        gsi: [
          {
            name: 'gsi_1',
            keys: {id2: 'HASH'},
            projection: {type: 'INCLUDE', attributes: ['item1', 'item2']},
            throughput: {read: 10, write: 10},
          },
          {
            name: 'gsi_2',
            keys: {id1: 'HASH', id3: 'RANGE'},
            projection: {type: 'ALL'},
            throughput: {read: 40, write: 40},
          },
        ],
        lsi: [
          {
            name: 'lsi_1',
            keys: {id1: 'HASH', id3: 'RANGE'},
            projection: {type: 'ALL'},
            throughput: {read: 40, write: 40},
          },
        ]
      )
      expect(aws_client.list_tables[:table_names]).to eq(['test_create_table'])
      data = aws_client.describe_table(table_name: 'test_create_table')[:table].to_hash
pp data
      expect(data[:table_name]).to eq('test_create_table')
      expect(data[:provisioned_throughput]).to eq({:number_of_decreases_today => 0, :read_capacity_units => 20, :write_capacity_units => 20})

    end
  end
end

