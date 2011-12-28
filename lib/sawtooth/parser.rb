require 'nokogiri'

require 'sawtooth/document'
require 'sawtooth/rules/set'

module Sawtooth
  class Parser
    attr_accessor :rules

    def initialize
      @rules = Sawtooth::Rules::Set.new
    end

    # Delegates to `Rules::Set#add`.
    def add(path, rule)
      rules.add(path, rule)
    end

    # Invokes a rule if present and responding to method
    # in question.
    #
    def invoke_start!(path, doc, namespace, name, attrs = {})
      rule = rules.find(path)
      rule.start(doc, namespace, name, attrs) if rule && rule.respond_to?(:start)
    end

    def invoke_finish!(path, doc, namespace, name, text = '')
      rule = rules.find(path)
      rule.finish(doc, namespace, name, text) if rule && rule.respond_to?(:finish)
    end

    # Parses and XML thingy, a filename, path, IO or content
    # from memory. Provides and optional encoding, which defaults
    # to `UTF-8`.
    def parse(thing, encoding = 'UTF-8', &block)
      Sawtooth::Document.new(self).tap do |doc|
        parser = Nokogiri::XML::SAX::Parser.new(doc, encoding)
        parser.parse(thing, &block)
      end
    end
  end
end