module Sawtooth
  module Rules

    # An entry in the `Set`.
    class RuleEntry

      # Both path and the rule are accessible.
      attr_accessor :path, :rule
      attr_reader :orig_path

      # Creates a new entry using path and the rule instance.
      def initialize(path, rule)
        self.path, self.rule = path, rule
      end

      def path=(path)
        @orig_path = path
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
      attr_reader :items

      # Creates a new rule set.
      def initialize
        @items = []
      end

      # Adds a new `RuleEntry`.
      def add(path, rule)
        self.items << RuleEntry.new(path, rule)
      end

      # Find a rule matching the supplied path (or path array), if not
      # an array, then it must be separated by `/`.
      #
      # If no matching rule is found, `default` is returned.
      def find(*path)
        path = path.flatten.join('/')
        match = self.items.find { |rule| rule.matches?(path) }
        match.rule if match
      end

      # Pretty print rules.
      def print_rules
        "".tap do |str|
          items.each { |entry| str << "#{entry.orig_path}  => #{entry.rule.print_rule}\n" }
        end
      end
    end
  end
end