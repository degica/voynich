# Voynich

Voynich is a secret storage library for Ruby on Rails backed by Amazon Key Management Service (KMS)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'voynich'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install voynich
    
### Generate Migration File

    $ rails g voynich:active_record
    $ rake db:migrate
    
## Configuration

Add this code to your initializer

```ruby
Voynich.configure(
  aws_access_key_id: 'aakid',
  aws_secret_access_key: 'asak',
  kms_cmk_id: 'cmk_id',
  aws_region: 'us-east-1'
)
```

## Usage

```ruby
## Create new encrypted data
### `create` method creates a new data key using KMS API and save the encrypted version of the key,
### then encrypt the plain value passed as an argument, save it, and return the UUID of the saved value
uuid = Voynich::Storage.new.create({credit_card: {number: "411111111111"}})
# => "131cd6e8-03da-48f7-bf99-672429c94e3f"

## Get decrypted data
### decrypting can be done by passing the UUID to `decrypt` method
data = Voynich::Storage.new.decrypt(uuid)
# => {credit_card: {number: "411111111111"}}
```

### ActiveModel integration

```ruby
class SomeModel < ActiveRecord::Base
  include Voynich::ActiveModel::Model
  
  voynich_attribute :secret_data
end

model = SomeModel.new
# You can assign any type of data
model.secret_data = {card_number: '1234567890123456'}

# when the model is saved, encrypted data and key is created
model.save

# You can see the UUID of the voynich data is assigned
model.voynich_secret_data_value
# => #<Voynich::ActiveRecord::Value id: 1, data_key_id: 1, uuid: "...", ciphertext: "{\"c\":\"chD9hCWePs+Cqg...">

# You can get decrypted data just like a normal attribute
model.secret_data # => {card_number: '1234567890123456'}
```

## TODO

- [] Data key rotation
- [] Path based tree structure
- [] S3 adapter
