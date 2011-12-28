require 'test_helper'

class Sawtooth::DocumentTest < MiniTest::Unit::TestCase

  # A fake Attribute, for testing
  FakeAttr = Struct.new(:localname, :value) do
    def self.build(hsh = {})
      hsh.map { |k,v| self.new(k, v) }
    end
  end

  # A fake delegate for testing
  class FakeDelegate
    attr_reader :args
    def path; @args[0] end
    def doc;  @args[1] end
    def node; @args[2] end
    def start_document(*args); @args = args end
    def end_document(*args); @args = args.dup end
    def start_element(*args); @args = args end
    def end_element(*args); @args = args.map { |e| e.dup } end
  end

  def setup
    @delegate = FakeDelegate.new
    @doc = Sawtooth::Document.new @delegate
  end

  def test_that_elements_can_be_pushed_onto_the_stack
    @doc.push "a"
    @doc.push "b"
    assert_equal %w{a b}, @doc.stack
  end

  def test_elements_can_be_pushed_using_lshift
    @doc << "a"
    @doc << "b"
    assert_equal %w{a b}, @doc.stack
  end

  def test_push_chaining
    @doc.push("a").push("b") << "c" << "d"
    assert_equal %w{a b c d}, @doc.stack
  end

  def test_that_elements_can_be_popped_from_the_stack
    @doc << "a" << "b"
    @doc.pop
    assert_equal %w{a}, @doc.stack
  end

  def test_that_pop_returns_popped_item
    @doc.push("a").push("b").push("c")
    assert_equal "c", @doc.pop
    assert_equal "b", @doc.pop
    assert_equal %w{a}, @doc.stack
  end

  def test_that_peek_looks_at_the_element
    @doc << "a" << "b" << "c"
    assert_equal "c", @doc.peek
    assert_equal "b", @doc.peek(1)
    assert_equal "a", @doc.peek(2)
    assert_nil @doc.peek(3)
  end

  def test_current_and_parent_peek_aliases
    @doc << "a" << "b" << "c"
    assert_equal "c", @doc.current
    assert_equal "b", @doc.parent
  end

  def test_root_method
    @doc << "a"
    assert_equal "a", @doc.root
    @doc << "b"
    assert_equal "a", @doc.root
  end

  def test_document_parsing
    @doc.start_document
    assert_equal 0, @doc.path.size
    assert_equal 1, @delegate.path.size
    assert_equal '@document', @delegate.path.first.name

    # <root type='array'>
    @doc.start_element_namespace 'root', FakeAttr.build({ 'type' => 'array' })
    assert_equal 1, @doc.path.size
    assert_equal 'root', @delegate.node.name

    # <root type='array'>
    #   <elem>
    @doc.start_element_namespace 'elem'
    assert_equal 2, @doc.path.size
    assert_equal "root/elem", @doc.path.join('/')

    #     text
    @doc.characters("   te")
    @doc.characters("xt\n  ")

    #   </elem>
    @doc.end_element_namespace 'elem'
    assert_equal 1, @doc.path.size
    assert_equal 'elem', @delegate.node.name
    assert_equal 'text', @delegate.node.text

    # </root>
    @doc.end_element_namespace 'root'
    assert_equal 0, @doc.path.size
    assert_equal 1, @delegate.path.size
    assert_equal 'root', @delegate.node.name
    assert_equal({ 'type' => 'array' }, @delegate.node.attributes)

    # end document
    @doc.end_document
    assert_equal 1, @delegate.path.size
    assert_equal '@document', @delegate.path.first.name
  end
end