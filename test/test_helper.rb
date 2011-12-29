require 'minitest/autorun'
require 'minitest/pride'

# load sawtooth
require 'sawtooth'

class MiniTest::Unit::TestCase

  # Root directory, for tests
  TEST_ROOT = File.dirname(__FILE__)

  # Testing Stack
  def doc; @doc ||= Sawtooth::Document.new end

  # Helper which creates a new Sawtooth::Document::Node
  # Instance.
  #
  def build_node!(name = "test", opts = {})
    Sawtooth::Document::Node.new(opts[:ns] || opts[:namespace], name, opts[:attrs] || opts[:attributes] || {}, opts[:txt] || opts[:text] || '')
  end

  # Path to a file in test/files
  def fixture_path(filename)
    "#{TEST_ROOT}/files/#{filename}"
  end
end
