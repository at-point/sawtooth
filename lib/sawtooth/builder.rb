require 'sawtooth/parser'
require 'sawtooth/rules'

module Sawtooth

  # Yield a builder instance and start working on pushing
  # rules around like crazy.
  #
  def self.rules(&block)
    Sawtooth::Builder.new(&block)
  end

  # Provides a nice and hopefully easy to use DSL to build rules and start
  # parsing XML documents with ease.
  #
  class Builder

    # Has access to a set of rules.
    attr_reader :rules

    # Creates a new instance.
    def initialize(&block)
      @rules = Sawtooth::Rules::Set.new
      self.instance_eval(&block) if block_given?
    end

    # Get a parser instance with the same set of
    # rules.
    def parser
      @parser ||= Sawtooth::Parser.new(:rules => self.rules)
    end

    # Shortcut method to parse some input, delegates to the
    # parser.
    def parse(thingy)
      parser.parse(thingy)
    end

    # Called before the document starts.
    def before(&block)
      rules.add('@document:before', Sawtooth::Rules::CallRule.new(:start => block)) if block_given?
    end

    # Called after the document has ended.
    def after(&block)
      rules.add('@document:after', Sawtooth::Rules::CallRule.new(:finish => block)) if block_given?
    end

    def on_start(path, &block)
      rules.add(path, Sawtooth::Rules::CallRule.new(:start => block)) if block_given?
    end

    # Called when the node has finished parsing, i.e. text and everything is available.
    #
    def on_finish(path, &block)
      rules.add(path, Sawtooth::Rules::CallRule.new(:finish => block)) if block_given?
    end
    alias_method :on_node, :on_finish

    # Perform a rule on a block, optionally pass in a custom rule instance.
    def on(path, rule = nil, &block)
      rule = block.arity <= 0 ? Sawtooth::Rules::CallRule.new(&block) : Sawtooth::Rules::CallRule.new(:start => block) if block_given?
      rules.add(path, rule) if rule
    end

    # Use and set a nodes text to the top object in the stack.
    #
    #    # Simple mapping, sets "name"
    #    on_text 'Person/Name'
    #
    #    # Custom mapping
    #    on_text 'Person/Name' => :lastname
    #
    #    # Data Conversion
    #    on_text('Person/Age') { |str| str.to_i }
    #
    #    # Multiple Mappings
    #    on_text 'Person/Name' => :lastname, 'Person/FirstName' => :firstname
    #
    # The `TextRule` tries to set the value using a setter, or a hash
    # accessor and the `document.top` object.
    def on_text(mappings = {}, &block)
      if mappings.respond_to?(:to_str)
        rules.add(mappings.to_str, Sawtooth::Rules::TextRule.new(&block))
      else
        mappings.each do |path, name|
          rules.add(path, Sawtooth::Rules::TextRule.new(name, &block))
        end
      end
    end

    def delegate(delegation = {})
      path = delegation.keys.find { |k| k.to_s =~ %r{/\*\*?\z} }
      cb_path = path.gsub(%r{/\*\*?\z}, '')
      to = delegation[path]
      prefix = delegation[:prefix] || path.gsub(%r{/?[^/]+/\*\*?\z}, '')

      rule = Sawtooth::Rules::DelegateRule.new(:path => path, :rules => to.respond_to?(:rules) ? to.rules : to, :prefix => prefix)
      rules.add(cb_path, rule.before_after_callbacks_rule)
      rules.add(path, rule)
    end

    # Pretty print rules.
    def to_pretty_s; rules.print_rules end
  end
end