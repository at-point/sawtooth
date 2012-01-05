module Sawtooth
  module Rules

    # Base Rule, provides three unimplemented methods, which
    # can be overriden by more specific rules - like the create
    # or call rule etc.
    #
    class Base

      # Called when the beginning of a matching XML node is encountered.
      #
      # - path, current (maybe rewritten) path
      # - document, the current sawtooth parser stack (`Sawtooth::Document`)
      # - node, the current node to process
      def start(path, document, node)
      end

      # Called when the end of a matching XML node is encountered.
      # If an element has no body, this method is called with an empty
      # string instead.
      #
      # - path, current (maybe rewritten) path
      # - document, the current sawtooth parser stack (`Sawtooth::Document`)
      # - node, the current node
      def finish(path, document, node)
      end

      # Basically calls inspect
      def print_rule; self.class.name end
    end
  end
end
