require 'sawtooth/rules/base'
require 'sawtooth/rules/set'

Dir[File.dirname(__FILE__) + '/rules/*_rule.rb'].each do |rule|
  require rule
end
