require 'spec_helper'

describe Dymos::Base do
  class Dummy < Dymos::Base
    attr_accessor :id, :name, :favorite

    def table_name
      'dummy'
    end

    def attribute_types
      {
          id: 'n',
          name: 's',
          favorite: 'ss'
      }
    end
  end

  before :all do
    Aws.config[:region] = 'us-west-1'
    Aws.config[:endpoint] = 'http://localhost:4567'
    Aws.config[:access_key_id] = 'XXX'
    Aws.config[:secret_access_key] = 'XXX'
    client = Aws::DynamoDB::Client.new
    client.delete_table(table_name: 'dummy') if client.list_tables[:table_names].include?('dummy')
    client.create_table(
        attribute_definitions: [
            {attribute_name: 'id', attribute_type: 'S'}
        ],
        table_name: 'dummy',
        key_schema: [
            {attribute_name: 'id', key_type: 'HASH'}
        ],
        provisioned_throughput: {
            read_capacity_units: 1,
            write_capacity_units: 1,
        })
    client.put_item(table_name: 'dummy', item: {id: 'hoge', name: '太郎', favorite: Set['a', 'b', 'c']})
    client.put_item(table_name: 'dummy', item: {id: 'fuga', name: '次郎'})
    client.put_item(table_name: 'dummy', item: {id: 'piyo', name: '三郎'})
  end


  let(:model) { Dummy.new }
  describe :table_name do
    it "table_nameはクラス名を返す" do
      expect(model.table_name).to eq('dummy')
    end
  end

  describe :attribute_types do
    it "attributeの定義を返す" do
      expect(model.attribute_types[:id]).to eq('n')
    end
  end

  describe :dynamo, :order => :defined do
    it "DynamoDb::Clientを返す" do
      expect(model.dynamo.class.name).to eq('Aws::DynamoDB::Client')
    end


    describe :all do
      it "リストを得る" do
        expect(model.all.size).to eq(3)
      end
    end

    describe :find do
      it "keyからitemを得る" do
        data = model.find("hoge")
        expect(data.name).to eq('太郎')
        expect(data.favorite).to eq(Set['a', 'b', 'c'])
      end
    end

    describe :save do
      it '記録する' do
        model = Dummy.new
        model.id = "pico"
        model.name = "四郎"
        model.favorite = Set['d', 'e', 'f']
        res = model.save
        expect(res.successful?).to eq(true)
      end
    end
  end
end

