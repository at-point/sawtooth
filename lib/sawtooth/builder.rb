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
      parser.add(path, Sawtooth::Rules::CallRule.new(:start => block)) if block_given?
    end

    # Called when the node has finished parsing, i.e. text and everything is available.
    #
    def on_finish(path, &block)
      parser.add(path, Sawtooth::Rules::CallRule.new(:finish => block)) if block_given?
    end
    alias_method :on_node, :on_finish

    def on(path, &block)
      if block_given?
        rule = block.arity <= 0 ? Sawtooth::Rules::CallRule.new(&block) : Sawtooth::Rules::CallRule.new(:start => block)
        parser.add(path, rule)
      end
    end

    def on_text(mappings = {}, &block)
      if mappings.respond_to?(:to_str)
        parser.add(mappings.to_str, Sawtooth::Rules::TextRule.new(&block))
      else
        mappings.each do |path, name|
          parser.add(path, Sawtooth::Rules::TextRule.new(name, &block))
        end
      end
    end

    def delegate(delegation = {})
      path = delegation.keys.find { |k| k.to_s =~ %r{/\*\*?\z} }
      to = delegation[path]
      prefix = delegation[:prefix] || path.gsub(%r{/[^/]+/\*\*?\z}, '')

      rule = Sawtooth::Rules::DelegateRule.new(:rules => to.respond_to?(:rules) ? to.rules : to, :prefix => prefix)
      parser.add(path, rule)
      parser.add(path.gsub(%r{/\*\*?\z}, ''), rule.before_after_callbacks_rule)
    end
  end
end