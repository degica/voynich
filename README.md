# Voynich

Voynich is a secret storage library for Ruby on Rails backed by Amazon Key Management Service (KMS)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'voynich', github: 'degica/voynich'
```

And then execute:

    $ bundle
    
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

Voynich provides 2 types of interfaces.

### Storage interface

`Storage` provides generic accessors for encrypted attributes.

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

If you use Voynich with ActiveRecord models, you can use `Voynich::ActiveModel::Model` module to integrate your model with Voynich tables. 

To use the module, run the following command. It will generate a migration file and add some lines to your model file.

    $ rails g voynich:model_attribute YourModel model_attribute
    
Now the attribute is managed by Voynich

```ruby
model = YourModel.new
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

- [ ] Data key rotation
- [ ] Path based tree structure
- [ ] S3 adapter

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/degica/voynich.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
