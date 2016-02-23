require "rails/generators/migration"
require "rails/generators/active_record"

module Voynich
  class ActiveRecordGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_paths << File.join(File.dirname(__FILE__), "templates")

    def create_migration_file
      migration_template "migration.rb", "db/migrate/create_voynich_tables.rb"
    end

    def self.next_migration_number(dirname)
      ::ActiveRecord::Generators::Base.next_migration_number dirname
    end
  end
end
