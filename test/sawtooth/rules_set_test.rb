require 'test_helper'

class Sawtooth::Rules::SetTest < MiniTest::Unit::TestCase
  def setup
    @set = Sawtooth::Rules::Set.new(99)
    @set.add "other/test/path", 10
    @set.add "otherPath/test/*", 11
    @set.add "other/**", 12
    @set.add "other/path", 13
    @set.add "some/path", 1
    @set.add "some/path/here", 2
  end

  def test_adding_rules
    assert_equal 2, @set.rules.last.rule
  end

  def test_matching_static_rules
    assert_equal 1, @set.find("some/path")
    assert_equal 2, @set.find("some/path/here")
    assert_equal 1, @set.find(%w{some path})
    assert_equal 2, @set.find('some', 'path', 'here')
  end

  def test_matching_glob_rules
    assert_equal 12, @set.find("other/didum")
    assert_equal 12, @set.find("other/didum/dadam")
    assert_equal 12, @set.find("other/path") # cannot be reached because of globbing
    assert_equal 11, @set.find("otherPath/test/didum")
    assert_equal 99, @set.find("otherPath/test")
  end
end
