# frozen_string_literal: true

require 'yaml'
require 'tty-prompt'

require_relative '../helpers/terminal_helpers'

client_type = get_client_type(TTY::Prompt.new)
clients = load_clients(client_type)

clients.each_with_index do |(key, value), index|
  puts (index + 1).to_s + ". #{key} #{value}"
end
