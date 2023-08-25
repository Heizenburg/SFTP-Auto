require 'yaml'
require_relative '../helpers/terminal_helpers'

YAML.load_file('lib/shoprite_clients.yml').each_with_index do |(key, value), index|
  puts "#{index + 1}".yellow + ". #{key} #{value}"
end