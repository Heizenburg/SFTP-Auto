class UserInputHandler
  DEFAULT_DAYS = 30
  
  def initialize(prompt, logger)
    @prompt = prompt
    @logger = logger
  end

  def get_prompt_info
    client_type = get_client_type
    clients = load_clients(client_type)
    {
      range: get_selected_clients(clients),
      days: DEFAULT_DAYS,
      clients: clients,
      source_location: get_source_location(client_type)
    }.transform_keys(&:to_sym)
  end

  private

  def get_client_type
    @prompt.select("\nSelect Retailer:", %w[shoprite okfoods clicks].map(&:capitalize))
  end

  def load_clients(client_type)
    retailer = client_type.downcase
    file_path = File.expand_path("../yaml_files/#{retailer}_clients.yml", __FILE__)

    begin
      YAML.load_file(file_path)
    rescue Errno::ENOENT => e
      raise StandardError, "Retailer file not found: #{file_path}, #{e.message}"
    rescue Psych::SyntaxError => e
      raise StandardError, "YAML syntax error in file: #{file_path}, #{e.message}"
    end
  end

  def get_selected_clients(clients)
    # First, ask the user if they want to list all clients
    if @prompt.yes?('Would you like to list all clients?')
      list_all_clients(clients)
    end

    # Then, ask if they want to provide a client range
    if @prompt.yes?('Provide client range?')
      range_input = @prompt.ask("Select clients by range between [1: #{clients.keys.first}] and [#{clients.size}: #{clients.keys.last}]:") do |q|
        q.in("1-#{clients.size}")
      end

      selected_range = parse_range_input(range_input)
      selected_clients = format_range_string(selected_range, clients)
      @logger.info("Range provided: #{selected_clients}".yellow)
      sleep(1.5)
      selected_range
    end
  end

  def list_all_clients(clients)
    @logger.info("Listing all clients:\n")
    clients.each_with_index do |(client, location), index|
      @logger.info("[#{index + 1}]: #{client} - #{location}")
    end
    clients.keys
    @logger.info("\n")
  end

  def get_source_location(client_type)
    env_variable = client_type.upcase
    source_location = ENV[env_variable]

    if source_location.nil? || source_location.empty?
      raise "Environment variable not found or empty for client type: #{client_type}. " \
            "Please make sure to set #{env_variable} to its local directory in the .env file."
    end

    source_location
  end

  def parse_range_input(range_input)
    raise ArgumentError, 'Input cannot be empty' if range_input.nil? || range_input.empty?

    range_delimiters = /[\s\-:.]/

    if range_input.include?('.') # User input for a single client
      num = range_input.split('.').first.strip.to_i
      [num, num]
    elsif range_input.match?(range_delimiters)  
      range_parts = range_input.split(range_delimiters).map(&:to_i)
      raise ArgumentError, 'Invalid range input format: more than two numbers' if range_parts.size != 2

      range_parts
    else
      [1, range_input.to_i]
    end
  end

  def format_range_string(range_numbers, clients)
    if range_numbers.uniq.length == 1
      "[#{range_numbers.first}: #{clients.keys[range_numbers.first - 1]}] Only"
    else
      range_numbers.map { |num| "[#{num}: #{clients.keys[num - 1]}]" }.join(' to ')
    end
  end
end