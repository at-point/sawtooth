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
          doc['@delegate:prefix'].push @delegate.prefix
          rule = @delegate.rules && @delegate.rules.find('@document:before')
          rule.start(doc, node) if rule && rule.respond_to?(:start)
        end

        def finish(doc, node)
          rule = @delegate.rules && @delegate.rules.find('@document:after')
          rule.finish(doc, node) if rule && rule.respond_to?(:finish)
          doc['@delegate:prefix'].pop
        end
      end

      # Access the set of rules and prefix.
      attr_accessor :rules, :prefix, :path

      # Initialize with a set of rules and a prefix
      def initialize(options = {}, &block)
        self.path = options[:path]
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

        rel = relative_path(doc)
        puts " >>> #{doc.path * '/'} @ #{rel} => #{rule.class.name}"

        rule.start(doc, node) if rule && rule.respond_to?(:start)
      end

      def finish(doc, node)
        rule = rules && rules.find(relative_path(doc))
        rule.finish(doc, node) if rule && rule.respond_to?(:finish)
      end

      def print_rule
        "#{self.class.name}, rules=[\n\t".tap do |str|
          str << rules.print_rules.split("\n").join("\n\t") << "\n" if rules && rules.respond_to?(:print_rules)
          str << "]"
        end
      end

      protected

        # Returns the relative current path, based
        # on the prefix.
        def relative_path(doc)
          abs_prefix = doc['@delegate:prefix'].join('/').gsub(%r{/+}, '/')
          doc.path.join('/').gsub(%r{\A#{abs_prefix}/?}, '')
        end
    end
  end
end
