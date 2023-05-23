require 'yaml'

require_relative 'helpers/terminal_helpers'

client_list = YAML.load_file('lib/shoprite_clients.yml')

client_list.each_with_index do |(key, value), index|
  puts "#{index + 1}. #{key} #{value}"
end