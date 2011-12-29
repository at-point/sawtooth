require 'nokogiri'

require 'sawtooth/document'
require 'sawtooth/rules/set'

module Sawtooth

  # Default Parser implementation, can be used as a
  # starting point for custom implementations.
  #
  class Parser

    # Array of accessible rules.
    attr_reader :rules

    # Creates a new instance.
    def initialize(options = {})
      @rules = Sawtooth::Rules::Set.new
    end

    # Delegates to `Rules::Set#add`.
    def add(path, rule)
      rules.add(path, rule)
    end

    # Recieved a comment node.
    def comment(path, doc, str); end

    # Start document callback
    def start_document(path, doc)
      rule = rules.find(path)
      rule.start(doc, nil) if rule && rule.respond_to?(:start)
    end

    # End document callback
    def end_document(path, doc)
      rule = rules.find(path)
      rule.finish(doc, nil) if rule && rule.respond_to?(:finish)
    end

    # Start element callback
    def start_element(path, doc, node)
      rule = rules.find(path)
      rule.start(doc, node) if rule && rule.respond_to?(:start)
    end

    # End document callback
    def end_element(path, doc, node)
      rule = rules.find(path)
      rule.finish(doc, node) if rule && rule.respond_to?(:finish)
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