describe Dymos::Query::Describe do

  describe 'build query', order: :defined do
    let(:builder) { Dymos::Query::Describe.new }

    it do
      builder.name('Thread')
      result = @client.describe_table(builder.build)
      expect(result.table[:table_name]).to eq('Thread')
    end
  end
end

