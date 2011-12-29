require 'sawtooth/rules/base'
require 'sawtooth/rules/call_rule'

module Sawtooth
  module Rules

    # Can delegate to another set of rules, can be used
    # to map the same rules to multiple tags.
    #
    # Delegates must be mapped using `path/**`
    class DelegateRule < Base

      class CallbacksRule < Base
        def initialize(delegate); @delegate = delegate end
        def start(doc, node)
          rule = @delegate.rules && @delegate.rules.find('@document:before')
          rule.start(doc, node) if rule && rule.respond_to?(:start)
        end

        def finish(doc, node)
          rule = @delegate.rules && @delegate.rules.find('@document:after')
          rule.finish(doc, node) if rule && rule.respond_to?(:finish)
        end
      end

      # Access the set of rules and prefix.
      attr_accessor :rules, :prefix

      # Initialize with a set of rules and a prefix
      def initialize(options = {}, &block)
        self.rules = options[:rules]
        self.prefix = options[:prefix] || ''
      end

      # Builds a special rule which invokes :before and :after callbacks on the
      # supplied set of rules.
      def before_after_callbacks_rule
        @before_after_callbacks_rule ||= CallbacksRule.new(self)
      end

      def start(doc, node)
        rule = rules && rules.find(relative_path(doc))
        rule.start(doc, node) if rule && rule.respond_to?(:start)
      end

      def finish(doc, node)
        rule = rules && rules.find(relative_path(doc))
        rule.finish(doc, node) if rule && rule.respond_to?(:finish)
      end

      protected

        # Returns the relative current path, based
        # on the prefix.
        def relative_path(doc)
          doc.path.join('/').gsub(%r{\A#{prefix}/?}, '')
        end
    end
  end
end
