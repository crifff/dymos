# Dymos
[![Build Status](https://travis-ci.org/hoshina85/dymos.svg?branch=master)](https://travis-ci.org/hoshina85/dymos)
[![Coverage Status](https://coveralls.io/repos/hoshina85/dymos/badge.png?branch=master)](https://coveralls.io/r/hoshina85/dymos?branch=master)

dynamodb model

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dymos'
```

install it yourself as:

    $ gem install dymos

## Usage


### テーブル生成

```ruby
Dymos::Query::CreateTable.name('ProductCatalogs')
  .attributes(category: 'S', title: 'S', ISBN:'S', price:'N')
  .keys(category: 'HASH', title: 'RANGE')
  .gsi([{name: 'global_index_isbn', keys: {ISBN: 'HASH'}, projection: {type: 'INCLUDE', attributes: [:title, :ISBN]}, throughput: {read: 20, write: 10}}])
  .lsi([{name: 'local_index_category_price', keys: {category: 'HASH', price: 'RANGE'}}])
  .throughput(read: 20, write: 10)
```

### モデル定義

```ruby
class Product < Dymos::Model
    table 'ProductCatalogs'
    field :category, :integer
    field :title, :string
    field :ISBN, :string
    field :price, :integer
    field :authors, :array
    field :created_at, :time
  end
```

### クエリ
#### 取得

```ruby
Product.all
```

```ruby
Product.find('Novels', 'The Catcher in the Rye') #key is category && title
```

```ruby
Product.where(category:'Comics').all
Product.where(category:'Comics').add_filter(:authors,:contains,'John Smith').all
Product.where(category:'Comics').desc.one
Product.index(:local_index_category_price).add_condition(:category,'Comics')add_condition(:price,:gt,10000).all
```

#### 保存

##### 新規
```ruby
product = Product.new(params)
product.save!
```

##### 更新
```ruby
product = Product.find(conditions)
product.price += 100
product.update!
```

```ruby
product = Product.find(conditions)
product.add(price:100).put(authors:['Andy','Bob','Charlie']).update!
```

## 削除
```ruby
product = Product.find(conditions)
product.add_expected(:price,10000).delete
```


## Contributing

1. Fork it ( https://github.com/hoshina85/dymos/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
