describe Dymos::Query::Scan do

  describe 'build query' do
    let(:builder) { Dymos::Query::Scan.new }

    it :name do
      builder.name('hoge')
      expect(builder.build).to eq({table_name: 'hoge'})
      # .attributes('item1', 'item2').limit(20).select('ALL_ATTRIBUTES')
      # .filter([[:item1, :eq, 1], [:item2, :begins_with, 'fuga']], :or)
    end
    it :name do
      builder.attributes('item1', 'item2')
      expect(builder.build).to eq({attributes_to_get: ['item1', 'item2']})
    end

    it :filter do
      builder.filter([[:item1, :eq, [1, 2, 3]], [:item2, :begins_with, 'fuga']], :or)
      expect(builder.build).to eq({scan_filter: {
                                    'item1' => {
                                      attribute_value_list: [1, 2, 3],
                                      comparison_operator: 'EQ'
                                    },
                                    'item2' => {
                                      attribute_value_list: ['fuga'],
                                      comparison_operator: 'BEGINS_WITH'
                                    }},
                                   conditional_operator: 'OR'
                                  })
    end

    it :add_filter, :filter_operator do
      builder.add_filter(:item1, [1, 2, 3]).add_filter(:item2, :begins_with, 'fuga').filter_operator(:or)
      expect(builder.build).to eq({scan_filter: {
                                    'item1' => {
                                      attribute_value_list: [1, 2, 3],
                                      comparison_operator: 'EQ'
                                    },
                                    'item2' => {
                                      attribute_value_list: ['fuga'],
                                      comparison_operator: 'BEGINS_WITH'
                                    }},
                                   conditional_operator: 'OR'
                                  })
    end

    it :start_key do
      builder.start_key(id: 1, hoge: 'fuga')
      expect(builder.build).to eq({exclusive_start_key: {"id" => 1, "hoge" => "fuga"}})
    end

    it '絞込' do
      builder.name(:ProductCatalog).add_filter(:Authors, :contains, "Author 1")
      result = @client.scan(builder.build)
      expect(result[:scanned_count]).to eq(8)
      expect(result[:count]).to eq(3)
    end

  end
end

