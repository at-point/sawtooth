require 'test_helper'

class Sawtooth::Rules::CreateRuleTest < MiniTest::Unit::TestCase
  def doc; @doc ||= Sawtooth::Document.new end

  def test_creates_instance_of_supplied_class
    rule = Sawtooth::Rules::CreateRule.new Hash
    assert_equal Hash, rule.clazz
    assert_equal false, rule.keep?
    assert_nil rule.creator

    rule.start(doc, build_node!)
    assert_instance_of Hash, doc.top

    rule.finish(doc, build_node!)
    assert_nil doc.top
  end

  def test_options_hash
    rule = Sawtooth::Rules::CreateRule.new :keep => true, :class => Array
    assert_equal Array, rule.clazz
    assert_equal true, rule.keep?
    assert_nil rule.creator

    rule.start(doc, build_node!)
    assert_instance_of Array, doc.top

    rule.finish(doc, build_node!)
    assert_equal [], doc.top
  end

  def test_creator_via_block
    rule = Sawtooth::Rules::CreateRule.new { "test" }
    assert_nil rule.clazz
    assert_equal false, rule.keep?

    rule.start(doc, build_node!)
    assert_equal "test", doc.top
  end
end