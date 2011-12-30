
                                                                   __
                                                       _____....--' .'
                                          _..___...---'._ o      -`(
                           _             | |  _         \   .--.  `\
        ___  __ ___      _| |_ ___   ___ | |_| |__      |   \   \ `|
       / __|/ _` \ \ /\ / / __/ _ \ / _ \| __| '_ \     |o o |  |  |
       \__ \ (_| |\ V  V /| || (_) | (_) | |_| | | |     \___'.-`.  '.
       |___/\__,_| \_/\_/  \__\___/ \___/ \__|_| |_|          |   `---'
      '^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'

A companion for [nokogori](http://nokogiri.org) to parse XML files by rules,
similar to [Apache Commons Digester](http://commons.apache.org/digester/).

Converting XML structures into Ruby is most often an unsatisfying task, having
to choose between implementing a SAX parser (for speed) or using _nokogiri_
features like CSS selectors for ease of use. At it's base _sawtooth_ is parsing
documents using SAX, but provides an interface to specify rules for the handling
the document.

    require 'open-uri'
    require 'sawtooth'

    rules = Sawtooth.rules do
      before { |doc| doc << [] }                  # 1. create an array for all news items

      on 'rss/channel/item' do
        on_start  { |doc| doc << Hash.new }       # 2. on an item create hash
        on_finish { |doc| doc.parent << doc.pop } # 3. when closing an item, pop from stack and
      end                                         #    append to parent array (from step 1.)

      on_text 'rss/channel/item/*'                # 4. add contents to hash
    end

    result = rules.parse(open('http://rss.cnn.com/rss/edition.rss')).root
    p result #=> [{ 'title' => 'Some CNN News...', 'guid' =>, ...}, ...]

This sample shows the DSL exposed to create the XML parsing rules for an RSS feed.
