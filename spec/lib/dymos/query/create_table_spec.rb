describe Dymos::Query::CreateTable do

  describe 'build query' do
    let(:builder) { Dymos::Query::CreateTable.new }

    it 'create文生成(スループットデフォルト値)' do
      builder.name('test_create_table').attributes(id: 'S').keys(id: 'HASH')
      expect(builder.build).to eq({:table_name => "test_create_table", :attribute_definitions => [{:attribute_name => "id", :attribute_type => "S"}], :key_schema => [{:attribute_name => "id", :key_type => "HASH"}], :provisioned_throughput => {:read_capacity_units => 10, :write_capacity_units => 5}})
      @client.delete_table(table_name: 'test_create_table') if @client.list_tables[:table_names].include?('test_create_table')
      @client.create_table(builder.build)
    end

    it '複雑なクエリ(インデックスのprojection省略するとALLになる)' do
      builder.name('test_create_table')
        .attributes(id1: 'S', id2: 'S', id3: 'N')
        .keys(id1: 'HASH', id2: 'RANGE')
        .throughput(read: 20, write: 20)
        .gsi([{name: 'gsi_1', keys: {id2: 'HASH'}, projection: {type: 'INCLUDE', attributes: ['item1', 'item2']}, throughput: {read: 10, write: 10}}])
        .lsi([{name: 'lsi_1', keys: {id1: 'HASH', id3: 'RANGE'}, throughput: {read: 40, write: 40}}])
      query = builder.build(provisioned_throughput: {read_capacity_units: 1, write_capacity_units: 1})

      expect(query).to eq({:table_name => "test_create_table",
                           :attribute_definitions => [{:attribute_name => "id1",
                                                       :attribute_type => "S"},
                                                      {:attribute_name => "id2",
                                                       :attribute_type => "S"},
                                                      {:attribute_name => "id3",
                                                       :attribute_type => "N"}],
                           :key_schema => [{:attribute_name => "id1",
                                            :key_type => "HASH"},
                                           {:attribute_name => "id2",
                                            :key_type => "RANGE"}],
                           :provisioned_throughput => {:read_capacity_units => 1,
                                                       :write_capacity_units => 1},
                           :global_secondary_indexes => [{:index_name => "gsi_1",
                                                          :key_schema => [{:attribute_name => "id2",
                                                                           :key_type => "HASH"}],
                                                          :projection => {:projection_type => "INCLUDE",
                                                                          :non_key_attributes => ["item1",
                                                                                                  "item2"]},
                                                          :provisioned_throughput => {:read_capacity_units => 10,
                                                                                      :write_capacity_units => 10}}],
                           :local_secondary_indexes => [{:index_name => "lsi_1",
                                                         :key_schema => [{:attribute_name => "id1",
                                                                          :key_type => "HASH"},
                                                                         {:attribute_name => "id3",
                                                                          :key_type => "RANGE"}],
                                                         :projection => {:projection_type => "ALL"}}]})

      @client.delete_table(table_name: 'test_create_table') if @client.list_tables[:table_names].include?('test_create_table')
      @client.create_table(query)
    end
  end

end

