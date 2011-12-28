module Sawtooth
  module Rules

    # Base Rule, provides three unimplemented methods, which
    # can be overriden by more specific rules - like the create
    # or call rule etc.
    #
    class Base

      # Called when the beginning of a matching XML node is encountered.
      #
      # - context, the current sawtooth parser stack
      # - namespace, the URI of the elements namespace (if any)
      # - name, the node name
      # - attributes, a hash with the node attributes
      def start(context, namespace, name, attributes = {})
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
      end
    end
  end
end
