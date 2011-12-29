require 'sawtooth/parser'
require 'sawtooth/rules'

module Sawtooth

  # Provides a nice and hopefully easy to use DSL to build rules and start
  # parsing XML documents with ease.
  #
  class Builder

    attr_reader :parser

    # Creates a new instance.
    def initialize(&block)
      @parser = Sawtooth::Parser.new
      self.instance_eval(&block) if block_given?
    end

    # Provide a block of rules.
    def rules(&block)
      self.instance_eval(&block) if block_given?
      self
    end

    def parse(thingy)
      parser.parse(thingy)
    end

    # DSL
    def on(path, &block)
      @rule = Sawtooth::Rules::MultiRule.new
      self.instance_eval(&block) if block_given?
      parser.add(path, @rule.flatten) unless @rule.empty?
      @rule = nil
    end

    # Pushes a root Element onto the stack.
    def root(clazz = nil, &block)
      parser.add('@document', Sawtooth::Rules::CreateRule.new(:class => clazz, :keep => true, &block))
    end

    # Execute a block at start or finish of an element.
    def call(pos = :finish, &block)
      @rule << Sawtooth::Rules::CallRule.new { pos == :finish ? at_finish(&block) : at_start(&block) } if @rule
    end

    # Add a create rule for the current path.
    #
    def create(clazz = nil, &block)
      @rule << Sawtooth::Rules::CreateRule.new(clazz, &block) if @rule
    end

    # Small custom handler currently which pushes the current item
    # to `peek(1)`.
    def push
      @rule << Sawtooth::Rules::CallRule.new do
        at_finish { |doc| doc.parent << doc.top }
      end if @rule
    end

    # Adds a `TextRule`
    def text(name = nil, &block)
      @rule << Sawtooth::Rules::TextRule.new(name, &block) if @rule
    end
  end
end