require 'sawtooth/rules/base'

module Sawtooth
  module Rules

    # The call rule allows to execute custom blocks
    # of code upon start or finish.
    #
    #    CallRule.new do
    #      at_start  { |doc, name, attrs| doc << name }
    #      at_finish { |doc, name, text| doc.pop }
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
      def at_start(&block)
        @options[:start] = block
      end

      # Configure the `on_finish` block.
      def at_finish(&block)
        @options[:finish] = block
      end

      # Called when the beginning of a matching XML node is encountered.
      #
      # - context, the current sawtooth parser stack
      # - namespace, the URI of the elements namespace (if any)
      # - name, the node name
      # - attributes, a hash with the node attributes
      def start(context, namespace, name, attributes = {})
        invoke_block @options[:start], context, name, attributes
      end

      # Called when the end of a matching XML node is encountered.
      # If an element has no body, this method is called with an empty
      # string instead.
      #
      # - context, the current sawtooth parser stack
      # - namespace, the URI of the element namespace (if any)
      # - name, the node name
      # - text, element body if any
      def finish(context, namespace, name, text = '')
        invoke_block @options[:finish], context, name, text
      end

      protected
        def invoke_block(block, document, name, arg = nil)
          case block.arity
            when 1; block.call(document)
            else block.call(document, name, arg)
          end if block && block.respond_to?(:call)
        end
    end
  end
end
