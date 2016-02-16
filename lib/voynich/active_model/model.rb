require 'active_support/concern'

module Voynich
  module ActiveModel
    module Model
      extend ActiveSupport::Concern

      included do
        before_save :voynich_store_attributes
      end

      def voynich_targets
        self.class.voynich_targets
      end

      def voynich_context(name)
        context_proc = voynich_targets[name.to_sym][:context]
        if context_proc
          context_proc.call(self)
        else
          {}
        end
      end

      def voynich_column_name(name)
        options = voynich_targets[name.to_sym]
        "#{options[:column_prefix]}#{name}#{options[:column_suffix]}"
      end

      def voynich_store_attributes
        voynich_targets.each do |name, options|
          iv = instance_variable_get(:"@#{name}")
          next if iv.nil?

          column_name = voynich_column_name(name)
          uuid = send(column_name)
          storage = Voynich::Storage.new
          context = voynich_context(name)
          if uuid.nil?
            send("#{column_name}=", storage.create(iv, context: context))
          else
            storage.update(uuid, iv, context: context)
          end
        end
      end

      VOYNICH_DEFAULT_OPTIONS = {
        column_prefix: 'voynich_',
        column_suffix: '_uuid'
      }

      module ClassMethods
        def voynich_targets
          @voynich_targets ||= {}
        end

        def voynich_attribute(name, options = {})
          options = VOYNICH_DEFAULT_OPTIONS.merge(options)
          voynich_targets[name.to_sym] = options

          define_method(name) do
            uuid = send(voynich_column_name(name))
            iv = instance_variable_get(:"@#{name}")
            return iv unless iv.nil?
            return nil if uuid.nil?
            storage = Voynich::Storage.new
            instance_variable_set(:"@#{name}", storage.decrypt(uuid, context: voynich_context(name)))
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
