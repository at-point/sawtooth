require 'sawtooth/rules/base'

module Sawtooth
  module Rules

    # Can contain multiple rules, finish is called
    # in reversed order.
    class MultiRule < Base

      attr_reader :rules

      def initialize
        @rules = []
      end

      # Is it empty, i.e. has no other rules.
      def empty?
        self.rules.empty?
      end

      def <<(rule)
        self.rules << rule
      end

      # Flatten rules, i.e. get rid of this MultiRule instance
      # if there's only one rule in it.
      def flatten
        self.rules.size == 1 ? self.rules.first : self
      end

      # Calls the creator and pushes item onto stack.
      def start(context, namespace, name, attributes = {})
        self.rules.each do |rule|
          rule.start(context, namespace, name, attributes) if rule.respond_to?(:start)
        end
      end

      # Removes object from stack
      def finish(context, namespace, name, text = '')
        self.rules.reverse.each do |rule|
          rule.finish(context, namespace, name, text) if rule.respond_to?(:finish)
        end
      end
    end
  end
end