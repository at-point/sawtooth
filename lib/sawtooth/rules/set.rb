require 'sawtooth/rules/base'

module Sawtooth
  module Rules

    # An entry in the `Set`.
    class RuleEntry

      # Creates a new entry using path and the rule instance.
      attr_accessor :path, :rule
      def initialize(path, rule)
        @path, @rule = path, rule
      end

      # Returns `true` if the current path matches.
      def matches?(test, flags = 0)
        File.fnmatch(self.path, test, flags)
      end
    end

    # Provides a set of routes and all the matching and globbing.
    #
    # Rules are matched using `File.fnmatch`.
    class Set

      # Accessor for the default rule, flags and the array of
      # rules.
      attr_reader :default, :flags, :rules

      # Creates a new rule set with the defined default rule
      def initialize(default = Sawtooth::Rules::Base.new, flags = 0)
        @default = default
        @flags = flags
        @rules = []
      end

      # Adds a new `RuleEntry`.
      def add(path, rule)
        self.rules << RuleEntry.new(path, rule)
      end

      # Find a rule matching the supplied path (or path array), if not
      # an array, then it must be separated by `/`.
      #
      # If no matching rule is found, `default` is returned.
      def find(*path)
        path = path.flatten.join('/')
        @rules.find { |rule| rule.matches?(path, self.flags) } || self.default
      end
    end
  end
end