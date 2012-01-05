require 'sawtooth/rules/base'

module Sawtooth
  module Rules

    # Sets a value on an object on the stack based on
    # the text contents of a tag.
    #
    # Inputs can further be converted by supplying a custom block
    # which converts the input, this is useful to perform e.g. parsing
    # dates or similar.
    #
    class TextRule < Base

      # Default Text Converter
      CONVERTER = Proc.new { |input| input = input.strip; input.length > 0 ? input : nil }

      # Settings
      attr_reader :name, :converter

      def initialize(name = nil, &block)
        @name = name
        @converter = block_given? ? block : CONVERTER
      end

      # If theres some text, send it to reciever (top object).
      def finish(path, doc, node)
        value = converter.call(node.text)
        attr_name = (self.name.respond_to?(:call) ? self.name.call(node.name) : self.name) || underscore(node.name)
        obj = doc.top

        case
          when obj.respond_to?("#{attr_name}="); obj.send("#{attr_name}=", value)
          when obj.respond_to?(:key?); obj[attr_name] = value
          when obj.respond_to?(:push); obj.push value
          # else, warning...?
        end if value
      end

      protected

        # Underscore a value, tries to fallback to AS if
        # available.
        def underscore(str)
          return str.underscore if str.respond_to?(:underscore)

          str.to_s.gsub(/::/, '/').
            gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            tr("-", "_").
            downcase
        end
    end
  end
end