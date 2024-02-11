require 'yaml'
require 'logger'

LOG_FILE = 'app.log'

def load_clients(file_path)
  YAML.load_file(file_path)
rescue Errno::ENOENT => e
  log_error("File not found: #{file_path}")
  {}
rescue Psych::SyntaxError => e
  log_error("YAML syntax error in file: #{file_path}, #{e.message}")
  {}
end

def log_error(message)
  logger = Logger.new(LOG_FILE)
  logger.error(message)
end

# Parse the given input to return the client range.  
def parse_range_input(range_input)
  range_delimiters = /[\s\-\:]/
  if range_input.include?('.')
    num = range_input.split('.').first.strip.to_i
    [num, num]
  elsif range_input.match?(range_delimiters)
    range_input.split(range_delimiters).map(&:to_i)
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
  provide_range = prompt.yes?("Do you want to provide a range?")
  return nil unless provide_range

  range_input = prompt.ask("Provide a range of clients between 1 and #{clients.size}:") { |q| q.in("1-#{clients.size}") }
  range_numbers = parse_range_input(range_input)

  range_str = format_range_string(range_numbers, clients)
  logger.info("Range provided: #{range_str}".yellow)
  sleep(1.5) # To give the user time to see the range provided.

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
