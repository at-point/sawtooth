require 'test_helper'

class Sawtooth::Rules::SetTest < MiniTest::Unit::TestCase
  def setup
    @set = Sawtooth::Rules::Set.new
  end

  def test_adding_rules
    @set.add "some/path", 1
    @set.add "some/path/here", 2
    assert_equal 2, @set.rules.last.rule
  end
end
