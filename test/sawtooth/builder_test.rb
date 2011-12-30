require 'test_helper'

class Sawtooth::BuilderTest < MiniTest::Unit::TestCase

  def test_using_basic_builder
    @builder = Sawtooth::Builder.new do
      before { |doc| doc << Array.new }
      after  { |doc| doc << doc.pop.first }

      on('statuses/status') do
        on_start  { |doc| doc << Hash.new }
        on_finish { |doc| doc.parent << doc.pop }
      end

      on_text('statuses/status/created_at' => :created_at) { |str| Date.parse(str) }
      on_text 'statuses/status/text' => :value
      on_text 'statuses/status/*' => Proc.new { |str| str.to_sym }
    end

    @doc = @builder.parse File.read(fixture_path('statuses.xml'))
    assert_equal 'I so just thought the guy lighting the Olympic torch was falling when he began to run on the wall. Wow that would have been catastrophic.', @doc.root[:value]
    assert_equal '2008-08-09', @doc.root[:created_at].strftime('%Y-%m-%d')
    assert_nil @doc.root[:screen_name]
    assert_equal 'web', @doc.root[:source]
  end

  def test_delegate_shortcut
    user = Sawtooth::Builder.new do
      before { |doc| doc << Hash.new }
      after  { |doc| doc.parent['user'] = doc.pop }

      on_text('user/name')
      on_text('user/screen_name')
      on_text('user/id') { |str| str.to_i }
    end

    builder = Sawtooth::Builder.new do
      before { |doc| doc << [] }
      after  { |doc| doc << doc.pop.last }

      on('statuses/status') do
        on_start  { |doc| doc << Hash.new }
        on_finish { |doc| doc.parent << doc.pop }
      end

      on_text('statuses/status/text')
      delegate('statuses/status/user/**' => user)
    end

    @doc = builder.parse File.read(fixture_path('statuses.xml'))
    assert_match /^Netshare will no longer start up for me\./, @doc.root['text']
    assert_equal 'John Nunemaker', @doc.root['user']['name']
    assert_equal 4243, @doc.root['user']['id']
  end
end