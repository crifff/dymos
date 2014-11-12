describe Dymos::Config do
  it 'config set' do
    Dymos::Config.default[:update_item]={
      return_values: 'ALL_OLD'
    }

    expect(Dymos::Config.default[:update_item]).to eq(return_values: 'ALL_OLD')

    Dymos::Config.default[:update_item]={}
  end
end