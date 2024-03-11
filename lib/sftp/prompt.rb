# frozen_string_literal: true

require 'yaml'
require 'logger'

# Add a method to prompt the user for the client type
def get_client_type(prompt)
  prompt.select("\nSelect Retailer:", %w[shoprite okfoods clicks].map(&:capitalize))
end

def load_clients(client_type)
  retailer = client_type.downcase

  begin
    YAML.load_file(File.expand_path("../yaml_files/#{retailer}_clients.yml", __FILE__))
  rescue Errno::ENOENT => e
    # Raise a StandardError if the file is not found
    raise StandardError, "Retailer file not found: #{client_type}_clients.yml, #{e.message}"
  rescue Psych::SyntaxError => e
    # Raise a StandardError if there is a YAML syntax error in the file
    raise StandardError, "YAML syntax error in file: #{client_type}_clients.yml, #{e.message}"
  end
end

# Add a method to get the source location based on the client type
def get_source_location(client_type)
  env_variable = client_type.upcase
  source_location = ENV[env_variable]

  if source_location.nil? || source_location.empty?
    raise "Environment variable not found or empty for client type: #{client_type}. " \
          "Please make sure to set #{env_variable} to its local directory in the .env file."
  end

  source_location
end

# Parse the given input to return a range.
def parse_range_input(range_input)
  range_delimiters = /[\s\-:.]/
  if range_input.nil? || range_input.empty?
    raise ArgumentError, "Input cannot be empty"
  end
  if range_input.include?('.')
    num = range_input.split('.').first.strip.to_i
    [num, num]
  elsif range_input.match?(range_delimiters)
    range_parts = range_input.split(range_delimiters).map(&:to_i)
    if range_parts.size != 2
      raise ArgumentError, "Invalid range input format"
    end
    range_parts
  else
    [1, range_input.to_i]
  end
end

# Formats the range string based on the range numbers and clients
def format_range_string(range_numbers, clients)
  if range_numbers.uniq.length == 1
    "[#{range_numbers.first}: #{clients.keys[range_numbers.first - 1]}] Only"
  else
    range_info = range_numbers.map { |num| "[#{num}: #{clients.keys[num - 1]}]" }
    "#{range_info.first} to #{range_info.last}"
  end
end

def get_range(prompt, clients, logger)
  provide_range = prompt.yes?('Do you want to provide a range?')
  return nil unless provide_range

  range_input = prompt.ask("Provide a range of clients between 1 and #{clients.size}:") do |q|
    q.in("1-#{clients.size}")
  end
  range_numbers = parse_range_input(range_input)

  range_str = format_range_string(range_numbers, clients)
  logger.info("Range provided: #{range_str}".yellow)
  sleep(1.5) # To give the user time to see the range provided.

  range_numbers
end

def process_clients_again?(prompt)
  mode = analysis_mode? ? 'analyze' : 'upload'
  prompt.yes?("Do you want to #{mode} any more clients?")
end

# Returns the default number of days as an integer.
def default_days
  30
end

# Retrieves prompt information based on the input prompt and logger
def get_prompt_information(prompt, logger)
  client_type = get_client_type(prompt)
  clients = load_clients(client_type)
  source_location = get_source_location(client_type)

  range = get_range(prompt, clients, logger)
  days = default_days

  logger.info("\n")

  { days: days, range: range, clients: clients, source_location: source_location }.tap do |hash|
    hash.keys.each do |key|
      hash[key.to_sym] = hash.delete(key)
    end
  end
end

