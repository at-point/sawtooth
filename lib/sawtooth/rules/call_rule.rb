require 'sawtooth/rules/base'

module Sawtooth
  module Rules

    # The call rule allows to execute custom blocks
    # of code upon start or finish.
    #
    #    CallRule.new do
    #      on_start  { |doc, name, attrs| doc << name }
    #      on_finish { |doc, name, text| doc.pop }
    #    end
    #
    class CallRule < Base

      # Should be initialized with a block, the
      # block invokes the current instance.
      def initialize(options = {}, &block)
        @options = options || {}
        self.instance_eval(&block) if block_given?
      end

      # Configure the `on_start` block.
      def on_start(&block)
        @options[:start] = block
      end

      # Configure the `on_finish` block.
      def on_finish(&block)
        @options[:finish] = block
      end

      # Called when the beginning of a matching XML node is encountered.
      #
      # - doc, the current sawtooth document stack
      # - node, the current node
      def start(path, doc, node)
        invoke_block @options[:start], doc, node
      end

      # Called when the end of a matching XML node is encountered.
      # If an element has no body, this method is called with an empty
      # string instead.
      #
      # - doc, the current sawtooth document stack
      # - node, the current node
      def finish(path, doc, node)
        invoke_block @options[:finish], doc, node
      end

      protected
        def invoke_block(block, doc, node)
          case block.arity
            when 1; block.call(doc)
            else block.call(doc, node)
          end if block && block.respond_to?(:call)
        end
    end
  end
end
