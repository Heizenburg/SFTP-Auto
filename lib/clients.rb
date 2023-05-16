require 'yaml'

client_list = YAML.load_file('lib/shoprite_clients.yml')

client_list.each_with_index do |(key, _), index|
  puts "#{index + 1}. #{key}"
end