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
      result = query.execute
      expect(result.include? :table_names).to eq(true)
    end
  end

end

