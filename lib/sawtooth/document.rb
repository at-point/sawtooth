require 'nokogiri/xml/sax'

module Sawtooth

  # Provides the current parser stack, delegates
  # basically all calles to the supplied parser.
  #
  # Also the document exposes methods which can be
  # used to directly interact with the stack.
  class Document < ::Nokogiri::XML::SAX::Document

    # Both the stack and the parser can be accessed.
    attr_reader :path, :stack, :parser

    # Creates a new Document instance with an empty stack
    # and the supplied parser. The parser is required to
    # apply the rules and is used to delegate several
    # method calls to.
    def initialize(parser)
      @parser = parser
      reset!
    end

    # Allow an element to be pushed onto the stack
    def <<(obj)
      stack << obj
      self
    end
    alias_method :push, :<<

    # Pop an element of the stack
    def pop
      stack.pop
      self
    end

    # Peek at an element in the stack, i.e. element 0 is the last
    # element.
    #
    #    doc.peek     # => returns last element
    #    doc.peek(1)  # => returns second last element
    #
    def peek(n = 0)
      stack[(n + 1) * -1]
    end

    # Shortcut method for current, i.e. an alias of peek without
    # an argument.
    def current; peek(0) end

    # Alias for `peek(1)`.
    def parent; peek(1); end

    # Resets path, stack and the current text.
    def reset!
      @path = []
      @stack = []
      @text = nil
    end

    # Characters and CDATA will be appended the current text block, if any
    def characters(str)
      @text ||= ""
      @text << str
    end
    alias_method :cdata_block, :characters

    # Called when comments are encountered, empty implementation,
    def comment(str); end

    # Called when document starts parsing, clears path and stack
    def start_document
      reset!
    end

    # Callend when document ends parsing, does nothing.
    def end_document; end

    # Called at the beginning of an element.
    def start_element_namespace(name, attrs_ary = [], prefix = nil, uri = nil, ns = [])
      @text = nil
      @path << name
      attrs = Hash[*attrs_ary.flatten]
      parser.invoke_rule!(:start, path, self, uri, name, attrs)
    end

    # Called at the end of an element.
    def end_element_namespace(name, prefix = nil, uri = nil)
      parser.invoke_rule!(:finish, path, self, uri, name, @text || '')
      @path.pop
      @text = nil
    end

    # Pass a warning along to the parser
    def warning(string)
      parser.warning(path, self, string)
    end

    # Pass an error along to the parser, parser should handle
    # whether to continue or abort parsing.
    def error(string)
      parser.error(path, self, string)
    end
  end
end