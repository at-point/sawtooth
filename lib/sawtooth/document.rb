require 'nokogiri/xml/sax'

module Sawtooth

  # Provides the current parser stack, delegates
  # basically all calles to the supplied parser.
  #
  # Also the document exposes methods which can be
  # used to directly interact with the stack.
  class Document < ::Nokogiri::XML::SAX::Document

    # A simple Document Node representation, for the node stack.
    Node = Struct.new(:namespace, :name, :attributes, :text) do
      def to_s; name end
    end

    class Stack < Array
      def peek(n = 0)
        self[(n + 1) * -1]
      end

      def current; peek(0) end
      alias_method :top, :current

      def parent; peek(-1) end

      def root; first end
    end

    # Special freaky node for the Document and Comments
    DOCUMENT_NODE = [Node.new(nil, '@document')]
    COMMENT_NAME  = '@comment'

    # Both the stack and the delegate can be accessed.
    attr_reader :stack, :stacks
    attr_accessor :delegate

    # Creates a new Document instance with an empty stack
    # and the supplied delegate. The delegate is required to
    # apply the rules.
    def initialize(delegate = nil)
      @delegate = delegate
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
    alias_method :top, :current

    # Alias for `peek(1)`.
    def parent; peek(1); end

    # Alias for `stack.first`
    def root; stack.first end

    # Get current path stack.
    def path; @path_stack end

    # Get current node.
    def node; @path_stack.last end

    # Direct access to customizeable stacks
    def [](key)
      stacks[key]
    end

    # Resets path, stack and the current text.
    def reset!
      @path_stack = []
      @stack = []
      @stacks = Hash.new { |hsh, k| hsh[k] = Stack.new }
      @text = nil
    end

    # Characters and CDATA will be appended the current text block, if any
    def characters(str)
      @text ||= ""
      @text << str
    end
    alias_method :cdata_block, :characters

    # Called when comments are encountered, empty implementation,
    def comment(str)
      cnode = Node.new(nil, COMMENT_NAME, {}, str)
      delegate.comment((DOCUMENT_NODE + path + [cnode]).compact, self, cnode) if delegate.respond_to?(:comment)
    end

    # Called when document starts parsing, clears path and stack
    # and calls with special @document path.
    def start_document
      reset!
      delegate.start_document(DOCUMENT_NODE, self) if delegate.respond_to?(:start_document)
    end

    # Callend when document ends parsing, does call with
    # special @document path.
    def end_document
      delegate.end_document(DOCUMENT_NODE, self) if delegate.respond_to?(:end_document)
    end

    # Called at the beginning of an element.
    def start_element_namespace(name, attrs_ary = [], prefix = nil, uri = nil, ns = [])
      @text = nil
      node = Node.new(uri, name, attrs_ary.inject({}) { |hsh, a| hsh[a.localname] = a.value; hsh }, '')
      path << node

      # call delegate
      delegate.start_element(path, self, node) if delegate.respond_to?(:start_element)
    end

    # Called at the end of an element.
    def end_element_namespace(name, prefix = nil, uri = nil)
      # fill text
      node.text = @text.to_s.strip if @text

      # call delegate
      delegate.end_element(path, self, node) if delegate.respond_to?(:end_element)

      # clear stack
      @path_stack.pop
      @text = nil
    end

    # Pass a warning along to the parser
    def warning(string)
      delegate.warning(path, self, string) if delegate.respond_to?(:warning)
    end

    # Pass an error along to the parser, parser should handle
    # whether to continue or abort parsing.
    def error(string)
      delegate.error(path, self, string) if delegate.respond_to?(:error)
    end
  end
end