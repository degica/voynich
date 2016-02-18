$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'voynich'
require 'database_cleaner'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include Voynich::SpecSupport::StubKMS

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:suite) do |example|
    DatabaseCleaner.clean
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before(:each) do
    Voynich.configure(kms_cmk_id: 'CMK_ID')
  end
end
