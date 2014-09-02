describe Dymos::Query::Attribute do
  describe :new do
    it "DynamoDBClientで取り扱う値の形式に変換" do
      # attribute = Dymos::Query::Attribute.new(:s, 'hoge')
      # attribute.==("hoge")
      # expect(attribute.data).to eq({s: 'hoge'})
    end
  end
end

