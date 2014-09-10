describe Dymos::Model do
  class DummyUser < Dymos::Model
    table :dummy
    field :id, :string
    field :name, :string
    field :email, :string
    field :list, :string_set

    validates :id, :presence => true
    validates :name, :presence => true, length: {maximum: 8}
    validates :email, :presence => true, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
  end

  class DummyPost < Dymos::Model
    table :post
    field :id, :number
    field :body, :string
    validates :id, :presence => true
    validates :body, :presence => true, length: {maximum: 256}
  end

  def sample_user_hash
    {id: 'hoge', name: '太郎', email: 'hoge@example.net', list: Set['a', 'b', 'c']}
  end

  before :all do
    Aws.config[:region] = 'us-west-1'
    Aws.config[:endpoint] = 'http://localhost:4567'
    Aws.config[:access_key_id] = 'XXX'
    Aws.config[:secret_access_key] = 'XXX'
    client = Aws::DynamoDB::Client.new

    client.delete_table(table_name: 'dummy') if client.list_tables[:table_names].include?('dummy')
    client.create_table(
        table_name: 'dummy',
        attribute_definitions: [
            {attribute_name: 'id', attribute_type: 'S'}
        ],
        key_schema: [
            {attribute_name: 'id', key_type: 'HASH'}
        ],
        provisioned_throughput: {
            read_capacity_units: 1,
            write_capacity_units: 1,
        })
    client.put_item(table_name: 'dummy', item: {id: 'hoge', name: '太郎', list: Set['a', 'b', 'c']})
    client.put_item(table_name: 'dummy', item: {id: 'fuga', name: '次郎'})
    client.put_item(table_name: 'dummy', item: {id: 'piyo', name: '三郎'})

    client.delete_table(table_name: 'post') if client.list_tables[:table_names].include?('post')
    client.create_table(
        table_name: 'post',
        attribute_definitions: [
            {attribute_name: 'id', attribute_type: 'S'},
            {attribute_name: 'timestamp', attribute_type: 'N'},
        ],
        key_schema: [
            {attribute_name: 'id', key_type: 'HASH'},
            {attribute_name: 'timestamp', key_type: 'RANGE'},
        ],
        provisioned_throughput: {
            read_capacity_units: 1,
            write_capacity_units: 1,
        })
  end

#  let(:model) { Dummy.new }

  describe "クラスマクロのデフォルト値" do
    it "設定されていなければnilを返す" do
      expect(DummyPost.new.id).to eq(nil)
    end

    class DummyModel < Dymos::Model
      field :id, :number, default: 0
      field :body, :string, default: "none"
    end

    it "idは0を返す" do
      expect(DummyModel.new.id).to eq(0)
    end

    it "bodyは'none'を返す" do
      expect(DummyModel.new.body).to eq('none')
    end

    it "上書きすることができる" do
      model = DummyModel.new
      model.id=1
      expect(model.id).to eq(1)
    end
  end

  describe :new do

    describe :field do
      it 'fieldで名前と型を定義' do
        model = DummyUser.new
        expect(model.methods).to include(:id, :id=, :id?, :id_type, :name, :name=, :name?, :name_type)
        model.id = 123
        expect(model.id).to eq(123)
        model.name = '太郎'
        expect(model.name).to eq('太郎')
        expect(model.name?).to eq(true)
        expect(model.name_type).to eq(:string)


        model = DummyPost.new
        expect(model.id).to eq(nil)
        expect(model.methods).to include(:id, :id=, :id?, :id_type, :body, :body, :body?, :body_type)
        expect(model.methods).not_to include(:name)

      end
    end

    it 'コンストラクタで定義' do
      model = DummyUser.new(sample_user_hash)
      expect(model.id).to eq('hoge')
      expect(model.name).to eq('太郎')
      expect(model.email).to eq('hoge@example.net')
      expect(model.list).to eq(Set['a', 'b', 'c'])
    end

  end

  describe :validate do
    it 'バリデート' do
      model = DummyUser.new(id: 'hoge', name: '', email: 'hoge')
      expect(model.valid?).to eq(false)
      model.name='太郎'
      expect(model.valid?).to eq(false)
      model.email='hoge@example.net'
      expect(model.valid?).to eq(true)
    end
  end

  describe :attributes= do
    it 'まとめて代入' do
      model = DummyUser.new
      model.attributes = sample_user_hash
      expect(model.id).to eq('hoge')
      expect(model.name).to eq('太郎')
      expect(model.email).to eq('hoge@example.net')
      expect(model.list).to eq(Set['a', 'b', 'c'])
    end
  end

  describe :attributes do
    it 'まとめて取得' do
      model = DummyUser.new(sample_user_hash)
      expect(model.attributes).to eq(sample_user_hash)
    end
  end

  describe :dynamo, :order => :defined do

    describe :describe do
      it "table情報を得る" do
        model = DummyUser.new
        expect(model.describe_table[:table][:table_name]).to eq('dummy')
        expect(model.describe_table[:table][:key_schema].first[:attribute_name]).to eq('id')
        expect(model.describe_table[:table][:key_schema].first[:key_type]).to eq('HASH')
      end
    end

    describe :global_indexes do
      it "キー情報" do
        model = DummyUser.new
        expect(model.global_indexes.first[:attribute_name]).to eq('id')
        expect(model.global_indexes.first[:key_type]).to eq('HASH')

        model = DummyPost.new
        expect(model.global_indexes.first[:attribute_name]).to eq('id')
        expect(model.global_indexes.first[:key_type]).to eq('HASH')
        expect(model.global_indexes.last[:attribute_name]).to eq('timestamp')
        expect(model.global_indexes.last[:key_type]).to eq('RANGE')
      end
    end

    describe :find do
      it "ユーザを抽出" do
        user = DummyUser.get.key(id: 'hoge').execute
        expect(user.id).to eq('hoge')
        expect(user.name).to eq('太郎')
      end
    end

    describe :save do
      it '書き込み' do
        user = DummyUser.new
        user.id = 'aiueo'
        user.name = '四郎'
        result = user.save
        expect(result).to eq(true)
      end
    end

    describe :all do
      it "すべてのユーザを抽出" do
        users = DummyUser.all
        expect(users.size).to eq(4)
      end
    end

    describe :find do
      it "ユーザを抽出" do
        user = DummyUser.find('hoge')
        expect(user.id).to eq('hoge')
        expect(user.name).to eq('太郎')
      end
    end
  end

  describe "変更検知" do
    class DummyModel < Dymos::Model
      field :id, :number, default: 0
      field :body, :string, default: "none"
    end

    it "新規モデル" do
      user = DummyModel.new
      expect(user.changes).to eq({})
      expect(user.changed?).to eq(false)
      user.id = 1
      expect(user.changed?).to eq(true)
      expect(user.changes).to eq({"id" => [0, 1]})
      user.body = "hoge"
      expect(user.changes).to eq({"id" => [0, 1], "body" => ['none', 'hoge']})
    end

    describe "DBから引いたモデル" do
      it "" do
        user = DummyUser.get.key(id: 'hoge').execute
        expect(user.changes).to eq({})
        expect(user.changed?).to eq(false)
        user.id = 1
        expect(user.changed?).to eq(true)
        expect(user.id_changed?).to eq(true)
        expect(user.changes).to eq({"id" => ["hoge", 1]})
      end
    end
  end
end

