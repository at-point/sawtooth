module Sawtooth
  module Rules

    # An entry in the `Set`.
    class RuleEntry

      # Both path and the rule are accessible.
      attr_accessor :path, :rule

      # Creates a new entry using path and the rule instance.
      def initialize(path, rule)
        self.path, self.rule = path, rule
      end

      def path=(path)
        case path
          when Regexp; @path = path
          else @path = %r{\A#{path.gsub('**', '.+').gsub('*', '[^/]+')}\z}
        end
      end

      # Returns `true` if the current path matches.
      def matches?(test)
        test =~ path
      end
    end

    # Provides a set of routes and all the matching and globbing.
    #
    # Rules are matched using `File.fnmatch`.
    class Set

      # Accessor for the array of rules.
      attr_reader :rules

      # Creates a new rule set.
      def initialize
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
        match = @rules.find { |rule| rule.matches?(path) }
        match.rule if match
      end
    end
  end
end