require 'test_helper'
require 'open-uri'

class Sawtooth::ReadmeTest < MiniTest::Unit::TestCase
  def test_primary_cnn_example
    rules = Sawtooth.rules do
      before { |doc| doc << [] }
      on 'rss/channel/item' do
        on_start  { |doc| doc << Hash.new }
        on_finish { |doc| doc.parent << doc.pop }
      end
      on_text 'rss/channel/item/*'
    end

    result = rules.parse(open('http://rss.cnn.com/rss/edition.rss')).root

    assert_instance_of Array, result
    assert_instance_of Hash, result.first
    assert_equal %w{guid title pub_date description link}.sort, result.first.keys.sort
  end
end
