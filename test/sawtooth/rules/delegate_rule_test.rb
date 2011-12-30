require 'test_helper'

class Sawtooth::Rules::DelegateRuleTest < MiniTest::Unit::TestCase

  include Sawtooth::Rules

  XML = '<didum><del><foo><bar>x</bar><baz>z</baz></foo></del><da>123</da></didum>'

  def setup
    @parser = Sawtooth::Parser.new
    @parser.add("didum", CallRule.new(:start => Proc.new { |doc| doc << Hash.new }))
    @parser.add("didum/da", TextRule.new)
  end

  def test_using_delgate_rule
    @rules = Sawtooth::Rules::Set.new
    @rules.add("@document:before", CallRule.new(:start => Proc.new { |doc| doc << Hash.new }))
    @rules.add("@document:after", CallRule.new(:finish => Proc.new { |doc| doc.parent['del'] = doc.pop }))
    @rules.add("foo/bar", TextRule.new)
    @rules.add("foo/baz", TextRule.new)

    @rule = Sawtooth::Rules::DelegateRule.new :prefix => "didum/del/", :rules => @rules
    @parser.add('didum/del', @rule.before_after_callbacks_rule)
    @parser.add('didum/del/**', @rule)
    obj = @parser.parse(XML).top
    assert_equal '123', obj['da']
    assert_equal({ 'baz' => 'z', 'bar' => 'x' }, obj['del'])
  end

  def test_using_prefix_delegate_rule
    @rules = Sawtooth::Rules::Set.new
    @rules.add("@document:before", CallRule.new(:start => Proc.new { |doc| doc << Hash.new }))
    @rules.add("@document:after", CallRule.new(:finish => Proc.new { |doc| doc.parent['del'] = doc.pop }))
    @rules.add("bar", TextRule.new)
    @rules.add("baz", TextRule.new)

    @rule = Sawtooth::Rules::DelegateRule.new :prefix => "didum/del/foo", :rules => @rules
    @parser.add('didum/del/foo', @rule.before_after_callbacks_rule)
    @parser.add('didum/del/foo/**', @rule)
    obj = @parser.parse(XML).top
    assert_equal '123', obj['da']
    assert_equal({ 'baz' => 'z', 'bar' => 'x' }, obj['del'])
  end
end
