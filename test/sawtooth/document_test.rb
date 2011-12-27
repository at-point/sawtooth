require 'test_helper'
require 'sawtooth/document'

class Sawtooth::DocumentTest < MiniTest::Unit::TestCase

  def setup
    @doc = Sawtooth::Document.new(nil)
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

  def test_that_pop_can_be_chained
    @doc.push("a").push("b").push("c").pop.pop
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
end