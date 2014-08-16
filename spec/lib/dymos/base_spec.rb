require 'spec_helper'

describe Dymos::Base do
  class Dummy < Dymos::Base
    attr_accessor :id, :name
    def attribute_types
      {
        id: 'n',
        name: 's'
      }
    end
  end
  let(:model) { Dummy.new }
  describe :table_name do
    it "table_nameはクラス名を返す" do
      expect(model.table_name).to eq('Dummy')
    end
  end

  describe :attribute_types do
    it "attributeの定義を返す" do
      expect(model.attribute_types[:id]).to eq('n')
    end
  end

  describe :dynamo do
    it "DynamoDb::Clientを返す" do
      expect(model.dynamo.class.name).to eq('Aws::DynamoDB::Client')
    end
  end
end

