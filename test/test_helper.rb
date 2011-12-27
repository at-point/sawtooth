require 'minitest/autorun'
require 'minitest/pride'

# load sawtooth
require 'sawtooth'

class MiniTest::Unit::TestCase

  # Root directory, for tests
  TEST_ROOT = File.dirname(__FILE__)

  # Path to a file in test/files
  def fixture_path(filename)
    "#{TEST_ROOT}/files/#{filename}"
  end
end
