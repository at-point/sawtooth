require 'test_helper'

class Sawtooth::BuilderTest < MiniTest::Unit::TestCase

  #def test_using_basic_builder
  #  @builder = Sawtooth::Builder.new do
  #    before { |doc| doc << Array.new }
  #    after  { |doc| doc << doc.pop.first }
  #
  #    on('statuses/status') do
  #      on_start  { |doc| doc << Hash.new }
  #      on_finish { |doc| doc.parent << doc.pop }
  #    end
  #
  #    on_text('statuses/status/created_at' => :created_at) { |str| Date.parse(str) }
  #    on_text 'statuses/status/text' => :value
  #    on_text 'statuses/status/*' => Proc.new { |str| str.to_sym }
  #  end
  #
  #  @doc = @builder.parse File.read(fixture_path('statuses.xml'))
  #  assert_equal 'I so just thought the guy lighting the Olympic torch was falling when he began to run on the wall. Wow that would have been catastrophic.', @doc.root[:value]
  #  assert_equal '2008-08-09', @doc.root[:created_at].strftime('%Y-%m-%d')
  #  assert_nil @doc.root[:screen_name]
  #  assert_equal 'web', @doc.root[:source]
  #end
  #
  #def test_delegate_shortcut
  #  user = Sawtooth::Builder.new do
  #    before { |doc| doc << Hash.new }
  #    after  { |doc| doc.parent['user'] = doc.pop }
  #
  #    on_text('user/name')
  #    on_text('user/screen_name')
  #    on_text('user/id') { |str| str.to_i }
  #  end
  #
  #  builder = Sawtooth::Builder.new do
  #    before { |doc| doc << [] }
  #    after  { |doc| doc << doc.pop.last }
  #
  #    on('statuses/status') do
  #      on_start  { |doc| doc << Hash.new }
  #      on_finish { |doc| doc.parent << doc.pop }
  #    end
  #
  #    on_text('statuses/status/text')
  #    delegate('statuses/status/user/**' => user)
  #  end
  #
  #  puts builder.rules.print_rules
  #
  #  @doc = builder.parse File.read(fixture_path('statuses.xml'))
  #  assert_match /^Netshare will no longer start up for me\./, @doc.root['text']
  #  assert_equal 'John Nunemaker', @doc.root['user']['name']
  #  assert_equal 4243, @doc.root['user']['id']
  #end

  def test_chained_delegate_rules

    order = []

    block = Sawtooth::Builder.new do
      on_text('Blocks/Title' => 'title', 'Blocks/Text' => 'text')
      after { order << "block" }
    end

    article = Sawtooth::Builder.new do
      before { |doc| doc << Hash.new }
      after  { |doc| order << "article"; doc.parent == doc.root ? doc.parent['sections'].first << doc.pop : doc.parent << doc.pop }

      delegate('Blocks/**' => block)
    end

    section = Sawtooth::Builder.new do
      before { |doc| doc << [] }
      after  { |doc| order << "section"; doc.parent['sections'] << doc.pop }

      delegate('Article/**' => article, :prefix => 'Article')
    end

    builder = Sawtooth::Builder.new do
      before { |doc| doc.push('sections' => [[]]) }
      after { |doc| order << "builder" }

      on_text('Articles/Author')
      on_text('Articles/Version') { |str| str.to_i }

      delegate('Articles/MainArticle/**' => article, :prefix => 'Articles/MainArticle')
      delegate('Articles/Section/**' => section, :prefix => 'Articles/Section')
    end

    @doc = builder.parse File.read(fixture_path('delegate.xml'))
    assert_equal 'lukas', @doc.root['author']
    assert_equal 35, @doc.root['version']

    assert_equal 1, @doc.stack.size
    assert_equal 2, @doc.root['sections'].size

    assert_equal 'Didum', @doc.root['sections'].last.first['title']
    assert_equal 'Barfoo', @doc.root['sections'].first.first['text']

    assert_equal %w{block article block article section block article block article builder}, order
  end
end
