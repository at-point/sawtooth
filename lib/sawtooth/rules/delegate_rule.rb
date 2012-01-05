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

        attr_reader :delegate

        def initialize(delegate); @delegate = delegate end
        def start(path, doc, node)
          rule = @delegate.rules && @delegate.rules.find('@document:before')
          rule.start(path, doc, node) if rule && rule.respond_to?(:start)
        end

        def finish(path, doc, node)
          rule = @delegate.rules && @delegate.rules.find('@document:after')
          rule.finish(path, doc, node) if rule && rule.respond_to?(:finish)
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

      def start(path, doc, node)
        new_path = relative_path(path)
        rule = rules && rules.find(new_path)
        rule.start(new_path, doc, node) if rule && rule.respond_to?(:start)
      end

      def finish(path, doc, node)
        new_path = relative_path(path)
        rule = rules && rules.find(new_path)
        rule.finish(new_path, doc, node) if rule && rule.respond_to?(:finish)
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
        def relative_path(path)
          path[self.prefix.size..-1].gsub(%r{^/}, '').tap do |pth|
            #puts "self.prefix=#{self.prefix}, path=#{path}, result=#{pth}"
          end
        end
    end
  end
end
