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
      self.rules(&block) if block_given?
    end

    # Provide a block of rules.
    def rules(&block)
      self.instance_eval(&block) if block_given?
      self
    end

    def parse(thingy)
      parser.parse(thingy)
    end

    def before(&block)
      parser.before_callback = block
    end

    def after(&block)
      parser.after_callback = block
    end

    def on_start(path, &block)
      parser.add(path, Sawtooth::Rules::CallRule.new(:start => block)) if block_given?
    end

    def on_finish(path, &block)
      parser.add(path, Sawtooth::Rules::CallRule.new(:finish => block)) if block_given?
    end

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
  end
end