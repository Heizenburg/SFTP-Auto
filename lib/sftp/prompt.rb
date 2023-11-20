require 'yaml'

# Load the client names from the YAML file
def load_clients(file_path)
  YAML.load_file(file_path)
rescue StandardError => e
  puts "Error loading clients: #{e.message}"
  {}
end

def parse_range_input(range_input)
  if range_input.include?('-') || range_input.include?(':') || range_input.include?(' ')
    range_input.split(/[\s\-\:]/).map(&:to_i)
  else
    (1..range_input.to_i).to_a
  end
end

def format_range_string(range_numbers, clients)
  range_names = range_numbers.map { |num| clients.keys[num - 1] }

  if range_numbers.size == 1
    range_names.first
  else
    "#{range_names.first} to #{range_names.last}"
  end
end

def get_range(prompt, clients, logger)
  provide_range = prompt.yes?("Do you want to provide a range?")
  return nil unless provide_range

  range_input = prompt.ask("Provide a range of clients between 1 and #{clients.size}:") { |q| q.in("1-#{clients.size}") }
  range_numbers = parse_range_input(range_input)

  range_str = format_range_string(range_numbers, clients)
  logger.info("Range provided: #{range_str}".yellow) # Log the range provided

  range_numbers
end

# Get range and delete days information
def get_prompt_information(prompt, clients, default_days = 30, logger)
  range = get_range(prompt, load_clients('lib/shoprite_clients.yml'), logger)
  days = default_days
  
  logger.info("\n")
  [days, range]
end