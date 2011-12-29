require 'test_helper'

class Sawtooth::DelegateTest < MiniTest::Unit::TestCase
  def setup
    @parser = Sawtooth::Parser.new
    @initRule = Sawtooth::Rules::CallRule.new(:start => Proc.new { |doc| doc << Array.new })
    @addRule = Sawtooth::Rules::TextRule.new
  end

  def test_adding_simple_rule_and_parsing_file
    @parser.add("statuses", @initRule)
    @parser.add("statuses/status/text", @addRule)
    doc = @parser.parse File.open(fixture_path('statuses.xml'))
    assert_equal 'I so just thought the guy lighting the Olympic torch was falling when he began to run on the wall. Wow that would have been catastrophic.', doc.peek.first
    assert_equal 20, doc.peek.size
  end
end