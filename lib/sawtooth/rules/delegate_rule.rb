require 'sawtooth/rules/base'

module Sawtooth
  module Rules

    # Can delegate to another set of rules, can be used
    # to map the same rules to multiple tags.
    #
    # Delegates must be mapped using `path/**`
    class DelegateRule < Base

      # Access the set of rules and prefix.
      attr_accessor :rules, :prefix

      # Initialize with a set of rules and a prefix
      def initialize(options = {}, &block)
        self.rules = options[:rules]
        self.prefix = options[:prefix] || ''
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
