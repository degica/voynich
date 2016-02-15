def establish_connection
  ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => ":memory:"
  )
end

establish_connection

load File.dirname(__FILE__) + '/schema.rb'
