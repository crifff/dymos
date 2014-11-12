describe Dymos::Query::Query do

  let(:builder) { Dymos::Query::Query.new }
  let(:result_count) { @client.query(builder.build)[:count] }

  it 'HASH search' do
    builder.name('ProductCatalog').where(Id: 101)
    expect(@client.query(builder.build)[:count]).to eq(1)
    builder.name('ProductCatalog').conditions([[:Id, 101]])
    expect(@client.query(builder.build)[:count]).to eq(1)
  end

  it 'HASH RANGE search' do
    builder.name('Thread').where(ForumName: 'DynamoDB', Subject: 'DynamoDB Thread 1')
    expect(@client.query(builder.build)[:count]).to eq(1)
    builder.name('Thread').where([:ForumName, :eq, 'DynamoDB'], [:Subject, :eq, 'DynamoDB Thread 1'])
    expect(@client.query(builder.build)[:count]).to eq(1)
    builder.name('Thread').conditions([[:ForumName, 'DynamoDB'], [:Subject, 'DynamoDB Thread 1']])
    expect(@client.query(builder.build)[:count]).to eq(1)
    builder.name('Thread').add_conditions(:ForumName, 'DynamoDB').add_conditions(:Subject, :eq, 'DynamoDB Thread 1')
    expect(@client.query(builder.build)[:count]).to eq(1)
  end

  it 'only HASH search' do
    builder.name('Reply').where(Id: 'DynamoDB#DynamoDB Thread 1')
    result = @client.query(builder.build)
    expect(result[:count]).to eq(3)
  end

  it :exclusive_start_key do
    builder.name('Reply').where(Id: 'DynamoDB#DynamoDB Thread 1').start_key(Id: 'DynamoDB#DynamoDB Thread 1', ReplyDateTime: "2011-12-11T00:40:57.165Z")
    result = @client.query(builder.build)
    expect(result[:count]).to eq(2)
  end

  describe :order do
    it :asc do
      builder.name('Reply').where(Id: 'DynamoDB#DynamoDB Thread 1').limit(1).asc
      result = @client.query(builder.build)
      expect(result[:items].first["ReplyDateTime"]).to eq("2011-12-11T00:40:57.165Z")
    end
    it :desc do
      builder.name('Reply').where(Id: 'DynamoDB#DynamoDB Thread 1').limit(1).desc
      result = @client.query(builder.build)
      expect(result[:items].first["ReplyDateTime"]).to eq("2011-12-25T00:40:57.165Z")
    end
  end

  it 'HASH RANGE with filter' do
    builder.name('Thread').where(ForumName: 'DynamoDB')
    expect(@client.query(builder.build)[:count]).to eq(2)

    builder.name('Thread').where(ForumName: 'DynamoDB').filter([[:Message, "DynamoDB thread 2 message text"]])
    expect(@client.query(builder.build)[:count]).to eq(1)
  end
end

