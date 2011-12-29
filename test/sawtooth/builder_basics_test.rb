require 'test_helper'

class Sawtooth::BuilderBasicsTest < MiniTest::Unit::TestCase

  def test_using_basic_builder
    @builder = Sawtooth::Builder.new do
      root Array

      on('statuses/status') do
        create(Hash)
        push
      end

      on('statuses/status/text') { text(:value) }
      on('statuses/status/created_at') do
        text(:created_at) { |str| Date.parse(str) }
      end
      on('statuses/status/*') { text(Proc.new { |str| str.to_sym }) }
    end

    @doc = @builder.parse File.read(fixture_path('statuses.xml'))
    assert_equal 'I so just thought the guy lighting the Olympic torch was falling when he began to run on the wall. Wow that would have been catastrophic.', @doc.root.first[:value]
    assert_equal '2008-08-09', @doc.root.first[:created_at].strftime('%Y-%m-%d')
    assert_nil @doc.root.first[:screen_name]
    assert_equal 'web', @doc.root.first[:source]
  end
end
