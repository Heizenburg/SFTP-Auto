require 'yaml'
require 'logger'

LOG_FILE = 'app.log'

def load_clients(file_path)
  YAML.load_file(file_path)
rescue StandardError => e
  log_error("Error loading clients: #{e.message}")
  {}
end

def log_error(message)
  logger = Logger.new(LOG_FILE)
  logger.error(message)
end

def parse_range_input(range_input)
  range_delimiters = /[\s\-\:]/
  if range_input.match?(range_delimiters)
    range_input.split(range_delimiters).map(&:to_i)
  else
    [1, range_input.to_i]
  end
end

def format_range_string(range_numbers, clients)
  range_info = range_numbers.map { |num| "[#{num}: #{clients.keys[num - 1]}]" }
  range_numbers.size == 1 ? range_info.first : "#{range_info.first} to #{range_info.last}"
end

def get_range(prompt, clients, logger)
  provide_range = prompt.yes?("Do you want to provide a range?")
  return nil unless provide_range

  range_input = prompt.ask("Provide a range of clients between 1 and #{clients.size}:") { |q| q.in("1-#{clients.size}") }
  range_numbers = parse_range_input(range_input)

  range_str = format_range_string(range_numbers, clients)
  logger.info("Range provided: #{range_str}".yellow) # Log the range provided
  sleep(1)

  range_numbers
end

def get_default_days
  30
end

def get_prompt_information(prompt, clients, logger)
  range = get_range(prompt, load_clients('lib/shoprite_clients.yml'), logger)
  days = get_default_days
  
  logger.info("\n")
  [days, range]
end
