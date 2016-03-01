require "rails/generators/migration"
require "rails/generators/active_record"

module Voynich
  class ModelAttributeGenerator < Rails::Generators::Base
    argument :model_class_name, type: :string
    argument :attribute_name, type: :string

    def include_module
      inject_into_file(model_file_path, after: %r{class\s+#{model_class_name}\s+<\s+ActiveRecord::Base\n}) do <<-'RUBY'
  include Voynich::ActiveModel::Model
RUBY
      end
    end

    def add_voynich_attribute
      inject_into_file(model_file_path, after: "include Voynich::ActiveModel::Model\n",) do <<-RUBY
  voynich_attribute :#{attribute_name}
RUBY
      end
    end

    def generate_migration
      generate "migration", "AddVoynich#{attribute_name.classify}ValueIdTo#{model_class_name.pluralize} voynich_#{attribute_name}_value_id:integer"
    end

    private

    def model_file_path
      File.join("app", "models", "#{model_class_name.underscore}.rb")
    end
  end
end
