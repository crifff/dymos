describe 'query' do
  class ProductCatalogModel < Dymos::Model
    table 'ProductCatalog'
    field :Id, :integer
    field :Title, :string
    field :ISBN, :string
    field :Price, :integer
    field :Authors, :array
    field :Dimensions, :string
    field :PageCount, :integer
    field :InPublication, :integer
    field :ProductCategory, :string
  end
  class ForumModel < Dymos::Model
    table 'Forum'
    field :Name, :string
    field :Category, :string
    field :Threads, :integer
    field :Messages, :string
    field :Views, :integer
    field :LastPostBy, :string
    field :LastPostDateTime, :time
  end
  class ThreadModel < Dymos::Model
    table 'Thread'
    field :ForumName, :string
    field :Subject, :string
    field :Message, :string
    field :LastPostedBy, :string
    field :Views, :integer
    field :Replies, :integer
    field :Views, :integer
    field :Answered, :string
    field :Tags, :array
    field :Option, :string
    field :LastPostDateTime, :time
  end
  class ReplyModel < Dymos::Model
    table 'Reply'
    field :Id, :string
    field :ReplyDateTime, :time
    field :Message, :string
    field :PostedBy, :string
  end

  describe :find do
    it 'only' do
      expect(ProductCatalogModel.find(101).Id).to eq(101)
    end
  end

  describe :all do
    it :only do
      result = ForumModel.all
      expect(result.count).to eq(2)
    end
    it :where do
      result = ThreadModel.where(ForumName: "DynamoDB").all
      expect(result.count).to eq(2)
    end

    it :add_filter do
      result = ThreadModel.where(ForumName: "DynamoDB").add_filter(:Tags, :contains, 'table').all
      expect(result.count).to eq(1)
    end

    it :index do
      result = ReplyModel.index(:PostedByIndex).where(Id: "DynamoDB#DynamoDB Thread 1").all
      expect(result.count).to eq(3)
      result = ReplyModel.index(:PostedByIndex).where(Id: "DynamoDB#DynamoDB Thread 1", PostedBy: "User A").all
      expect(result.count).to eq(2)
      result = ReplyModel.index(:PostedByIndex).
        where(Id: "DynamoDB#DynamoDB Thread 1", PostedBy: "User A").all
      expect(result.count).to eq(2)
    end

    describe :filter_expression do
      it :scan do
        result =ThreadModel.expression("ForumName = :name").bind_values(name: "DynamoDB").all
        expect(result.count).to eq(2)
      end
      it :query do
        result =ThreadModel.where(ForumName: "DynamoDB").filter_expression("contains(#column, :number)")
                  .bind_names(column: "Subject")
                  .bind_values(number: "Thread 1").all
        expect(result.count).to eq(1)
      end
    end

    describe :conditions do
      describe :time do
        it :== do
          time = Time.parse("2011-12-11T00:40:57.165Z")
          result = ReplyModel.add_filter(:ReplyDateTime, :eq, time.iso8601(3)).all
          expect(result.count).to eq(1)
        end
        it :> do
          time = Time.parse("2011-12-11T00:40:57.165Z")
          result = ReplyModel.add_filter(:ReplyDateTime, :gt, time.iso8601(3)).all
          expect(result.count).to eq(4)
        end
        it :>= do
          time = Time.parse("2011-12-11T00:40:57.165Z")
          result = ReplyModel.add_filter(:ReplyDateTime, :ge, time.iso8601(3)).all
          expect(result.count).to eq(5)
        end
        it :< do
          time = Time.parse("2012-01-03T00:40:57.165Z")
          result = ReplyModel.add_filter(:ReplyDateTime, :lt, time.iso8601(3)).all
          expect(result.count).to eq(4)
        end
        it :<= do
          time = Time.parse("2012-01-03T00:40:57.165Z")
          result = ReplyModel.add_filter(:ReplyDateTime, :le, time.iso8601(3)).all
          expect(result.count).to eq(5)
        end
        it :<= do
          time = Time.parse("2012-01-03T00:40:57.165Z")
          result = ReplyModel.add_filter(:ReplyDateTime, :le, time.iso8601(3)).all
          expect(result.count).to eq(5)
        end
        it :null do
          result = ThreadModel.add_filter(:Hoge, :null).all
          expect(result.count).to eq(3)
        end
        it :not_null do
          result = ThreadModel.add_filter(:Hoge, :not_null).all
          expect(result.count).to eq(0)
        end
      end
    end
  end
  it :one do
    result = ThreadModel.where(ForumName: "DynamoDB").desc.one
    expect(result.Subject).to eq("DynamoDB Thread 2")
    result = ThreadModel.where(ForumName: "DynamoDB").asc.one
    expect(result.Subject).to eq("DynamoDB Thread 1")
  end

  describe :save do
    table='test_model_save_item_table'

    class TestModelSaveItem < Dymos::Model
      table 'test_model_save_item_table'
      field :id, :string
      field :param1, :integer
      field :param2, :integer
      field :param3, :string
      field :param4, :array
    end
    before :all do
      @client.delete_table(table_name: table) if @client.list_tables[:table_names].include?(table)
      query=Dymos::Query::CreateTable.new.name(table).attributes(id: 'S').keys(id: 'HASH').build
      @client.create_table(query)
      @client.put_item(table_name: table, item: {id: 'hoge', param1: 101, param2: 201, param3: "hoge", param4: [1, 0, 1]})
      @client.put_item(table_name: table, item: {id: 'fuga', param1: 102, param2: 202, param3: "fuga", param4: [1, 0, 2]})
      @client.put_item(table_name: table, item: {id: 'piyo', param1: 103, param2: 203, param3: "piyo", param4: [1, 0, 3]})
    end

    describe :new do
      it '通常のsave' do
        data={id: 'abc', param1: 104, param2: 204, param3: 'abc', param4: [1, 0, 4]}
        model = TestModelSaveItem.new(data)
        expect(model.save!).to eq(true)
        expect(TestModelSaveItem.find('abc').attributes).to eq(data)
      end

      it 'itemメソッドからパラメータを追加するとモデルの値は影響を受けない' do
        model = TestModelSaveItem.new
        data={id: 'efg', param1: 105, param2: 205, param3: 'efg', param4: [1, 0, 5]}
        expect(model.item(data).save!).to eq(true)
        expect(model.id).to eq(nil)
        expect(TestModelSaveItem.find('efg').attributes).to eq(data)
      end
    end

    describe :update do
      it 'addメソッドから値を変更' do
        model = TestModelSaveItem.find('hoge')
        expect(model.param1).to eq(101)
        expect(model.add(:param1, 1).update!).to eq(true)
        expect(model.last_execute_query[:query][:attribute_updates]).to eq({"param1" => {:value => 1, :action => "ADD"}})
        expect(model.param1).to eq(101)
        expect(TestModelSaveItem.find('hoge').param1).to eq(102)
      end


      it 'モデルの値の変更されたものだけアップデートする' do
        model = TestModelSaveItem.find('fuga')
        expect(model.param1).to eq(102)
        model.param1+=1
        expect(model.update!).to eq(true)
        expect(model.last_execute_query[:query][:attribute_updates]).to eq({"param1" => {:value => 103, :action => "PUT"}})
        model = TestModelSaveItem.find('fuga')
        expect(model.param1).to eq(103)
      end
    end
    describe :delete do
      it 'del' do
        model = TestModelSaveItem.find('piyo')
        expect(model.add_expected(:param1, :eq, 103).delete.class).to eq(TestModelSaveItem)
        expect(TestModelSaveItem.find('piyo')).to eq(nil)
      end
    end
  end
end

