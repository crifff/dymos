describe Dymos::Query::GetItem do

  describe 'build query' do
    let(:builder) { Dymos::Query::GetItem.new }

    subject { @client.get_item(builder.build).item }
    it do
      builder.name('Reply').key(Id: "DynamoDB#DynamoDB Thread 1", ReplyDateTime: "2011-12-18T00:40:57.165Z").attributes(:ReplyDateTime, "Message")

      is_expected.to eq({"ReplyDateTime" => "2011-12-18T00:40:57.165Z", "Message" => "DynamoDB Thread 1 Reply 1 text"})
    end
  end


end


