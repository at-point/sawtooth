require 'test_helper'

class Sawtooth::Rules::DelegateRuleTest < MiniTest::Unit::TestCase

  include Sawtooth::Rules

  XML = '<didum><del><foo><bar>x</bar><baz>z</baz></foo></del><da>123</da></didum>'

  def setup
    @parser = Sawtooth::Parser.new
    @parser.add("didum", CallRule.new(:start => Proc.new { |doc| doc << Hash.new }))
    @parser.add("didum/da", TextRule.new)

    create_rule = CallRule.new do
      on_start { |doc| doc.push Hash.new }
      on_finish { |doc| obj = doc.pop; doc.top['del'] = obj }
    end

    @rules = Sawtooth::Rules::Set.new
    @rules.add("foo", create_rule)
    @rules.add("foo/bar", TextRule.new)
    @rules.add("foo/baz", TextRule.new)
  end

  def test_using_delgate_rule
    @rule = Sawtooth::Rules::DelegateRule.new :prefix => "didum/del/", :rules => @rules
    @parser.add('didum/del/**', @rule)
    obj = @parser.parse(XML).top
    assert_equal '123', obj['da']
    assert_equal({ 'baz' => 'z', 'bar' => 'x' }, obj['del'])
  end
end
