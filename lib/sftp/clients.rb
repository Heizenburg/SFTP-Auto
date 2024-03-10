# frozen_string_literal: true

require 'yaml'
require 'tty-prompt'

require_relative '../helpers/terminal_helpers'
require_relative '../sftp/prompt'

prompt = TTY::Prompt.new

client_type = get_client_type(prompt)
clients = load_clients(client_type)

clients.each_with_index do |(key, value), index|
  puts (index + 1).to_s + ". #{key} #{value}"
end
