require 'sawtooth/rules/base'

module Sawtooth
  module Rules

    # Creates a new instance of a class or object and pushes
    # it onto the stack.
    #
    # The object is always created on `start`.
    class CreateRule < Base

      attr_reader :clazz, :keep, :creator

      def initialize(options = {}, &block)
        @keep = options.is_a?(Hash) ? !!options[:keep] : false
        @clazz = options.is_a?(Class) ? options : options[:class]
        @creator = block if block_given?
      end

      # Should the item be kept, i.e. not poped of the stack upon finish?
      def keep?; !!keep end

      # Calls the creator and pushes item onto stack.
      def start(document, node)
        obj = creator ? creator.call : clazz.new
        document.push obj
      end

      # Removes object from stack
      def finish(document, node)
        document.pop unless keep?
      end
    end
  end
end