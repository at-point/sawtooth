require 'sawtooth/rules/base'

module Sawtooth
  module Rules

    # Creates a new instance of a class or object and pushes
    # it onto the stack.
    #
    # The object is always created on `start`.
    class TextRule < Base

      # Default Text Converter
      CONVERTER = Proc.new { |input| input = input.strip; input.length > 0 ? input : nil }

      attr_reader :name, :converter

      def initialize(name = nil, &block)
        @name = name
        @converter = block_given? ? block : CONVERTER
      end

      # If theres some text, send it to reciever (top object).
      def finish(context, namespace, tagname, text = '')
        value = converter.call(text)
        attr_name = name || tagname.downcase
        obj = context.top

        case
          when obj.respond_to?("#{attr_name}="); obj.send("#{attr_name}=", value)
          else obj[attr_name] = value
          # else, send warning to parser (!)
        end if value
      end
    end
  end
end