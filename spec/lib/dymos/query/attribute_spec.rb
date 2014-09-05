describe Dymos::Query::Attribute do
  describe :new do
    describe "DynamoDBClientで取り扱う値の形式に変換" do
      it "文字列" do
        attribute = Dymos::Query::Attribute.new('10')
        expect(attribute.data).to eq(10)
      end
      it "数値に変換可能な文字列はintになる" do
        attribute = Dymos::Query::Attribute.new('10')
        expect(attribute.data).to eq(10)
      end
    end
  end
end

