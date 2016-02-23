require 'active_support/concern'

module Voynich
  module ActiveModel
    module Model
      extend ActiveSupport::Concern

      included do
        delegate :voynich_targets, to: :class
        delegate :voynich_column_name, to: :class
        before_save :voynich_store_attributes
      end

      def voynich_context(name)
        context_proc = voynich_targets[name.to_sym][:context]
        if context_proc
          context_proc.call(self)
        else
          {}
        end
      end

      def voynich_store_attributes
        voynich_targets.each do |name, options|
          iv = instance_variable_get(:"@#{name}")
          next if iv.nil?

          column_name = voynich_column_name(name)
          context = voynich_context(name)
          value = send(column_name)
          if value.nil?
            value = Voynich::ActiveRecord::Value.create!(plain_value: iv, context: context)
            send("#{column_name}=", value)
          else
            value.context = context
            value.plain_value = iv
            value.save!
          end
        end
      end

      VOYNICH_DEFAULT_OPTIONS = {
        column_prefix: 'voynich_',
        column_suffix: '_value',
        context: nil
      }

      module ClassMethods
        def voynich_targets
          @voynich_targets ||= {}
        end

        def voynich_column_name(name)
          options = voynich_targets[name.to_sym]
          "#{options[:column_prefix]}#{name}#{options[:column_suffix]}"
        end

        def voynich_attribute(name, options = {})
          options = VOYNICH_DEFAULT_OPTIONS.merge(options)
          voynich_targets[name.to_sym] = options
          asoc_options = options.
                         merge(class_name: "::Voynich::ActiveRecord::Value").
                         reject{|k| VOYNICH_DEFAULT_OPTIONS.keys.include? k}

          belongs_to :"#{voynich_column_name(name)}", asoc_options

          define_method(name) do
            value = send(voynich_column_name(name))
            iv = instance_variable_get(:"@#{name}")
            return iv unless iv.nil?
            return nil if value.nil?
            value.context = voynich_context(name)
            instance_variable_set(:"@#{name}", value.decrypt)
          end

          define_method("#{name}=") do |val|
            instance_variable_set(:"@#{name}", val)
          end

          define_method("#{name}?") do
            value = send(name)
            value.respond_to?(:empty?) ? !value.empty? : !!value
          end
        end
      end
    end
  end
end
