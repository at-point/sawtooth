require 'test_helper'

class Sawtooth::Rules::TextRuleTest < MiniTest::Unit::TestCase

  # Test Class
  SomeModel = Struct.new(:first_name)

  def test_setting_value_open_model
    doc.push SomeModel.new
    rule = Sawtooth::Rules::TextRule.new
    rule.finish("root/firstName", doc, build_node!("firstName", :text => "Hans"))
    assert_equal "Hans", doc.top.first_name
  end

  def test_setting_value_to_hash
    doc.push Hash.new
    rule = Sawtooth::Rules::TextRule.new
    rule.finish("root/firstName", doc, build_node!("firstName", :text => "Hans"))
    assert_equal "Hans", doc.top['first_name']
  end

  def test_supply_custom_name
    doc.push SomeModel.new
    rule = Sawtooth::Rules::TextRule.new :first_name
    rule.finish("root/didum/Text", doc, build_node!("Text", :text => "Hans"))
    assert_equal "Hans", doc.top.first_name
  end

  def test_supply_conversion_block
    doc.push Hash.new
    rule = Sawtooth::Rules::TextRule.new(:value) { |str| str.strip.to_i }
    rule.finish("root/didum/intValue", doc, build_node!("intValue", :text => "   1234\n"))
    assert_equal 1234, doc.top[:value]
  end

  def test_supply_name_conversion_block
    doc.push Hash.new
    rule = Sawtooth::Rules::TextRule.new(Proc.new { |name| name.upcase.to_sym })
    rule.finish("root/dadam/intValue", doc, build_node!("intValue", :text => "   1234\n"))
    rule.finish("root/dadam/strValue", doc, build_node!("strValue", :text => "   didum\n"))
    assert_equal "1234", doc.top[:INTVALUE]
    assert_equal "didum", doc.top[:STRVALUE]
  end

  def test_default_converter_converts_empty_line_to_nil
    doc.push SomeModel.new
    rule = Sawtooth::Rules::TextRule.new
    rule.finish("root/firstName", doc, build_node!("firstName", :text => "    \n"))
    assert_nil doc.top.first_name
  end

  def test_appends_values_if_array
    doc.push []
    rule = Sawtooth::Rules::TextRule.new
    rule.finish("root/firstName", doc, build_node!("firstName", :text => "Hans\n"))
    rule.finish("root/lastName",  doc, build_node!("lastName", :text => "    Muster\n\n"))
    assert_equal %w{Hans Muster}, doc.top
  end
end