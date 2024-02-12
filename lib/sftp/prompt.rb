require 'yaml'
require 'logger'

LOG_FILE = 'app.log'

# Add a method to prompt the user for the client type
def get_client_type(prompt)
  prompt.select("\nSelect Retailer:", %w(shoprite okfoods).map(&:capitalize))
end

# Modify the load_clients method to load the appropriate clients based on the user's input
def load_clients(client_type)
  case client_type
  when 'Shoprite'
    YAML.load_file('lib/shoprite_clients.yml')
  when 'Okfoods'
    YAML.load_file('lib/okfoods_clients.yml')
  else
    raise 'Invalid client type'
  end
rescue Errno::ENOENT => e
  log_error("File not found: #{client_type}_clients.yml")
  {}
rescue Psych::SyntaxError => e
  log_error("YAML syntax error in file: #{client_type}_clients.yml, #{e.message}")
  {}
end

# Add a method to get the source location based on the client type
def get_source_location(client_type)
  case client_type
  when 'Shoprite'
    ENV['SHOPRITE']
  when 'Okfoods'
    ENV['OKFOODS']
  else
    raise 'Invalid client type'
  end
end

def log_error(message)
  logger = Logger.new(LOG_FILE)
  logger.error(message)
end

# Parse the given input to return client to cycle.  
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

def process_clients_again?(prompt)
  mode = analysis_mode? ? "analyze" : "upload"
  prompt.yes?("\nDo you want to #{mode} any more clients?")
end

def get_default_days
  30
end

def get_prompt_information(prompt, logger)
  client_type = get_client_type(prompt)

  clients = load_clients(client_type)
  source_location = get_source_location(client_type)

  range = get_range(prompt, clients, logger)
  days = get_default_days

  logger.info("\n")
  [days, range, clients, source_location]
end
