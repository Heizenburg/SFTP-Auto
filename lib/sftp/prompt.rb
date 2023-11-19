# Split range by space, hyphen, dash, and colon.
def get_range(prompt, clients)
  provide_range = prompt.yes?("Do you want to provide a range?")
  return nil unless provide_range

  range_input = prompt.ask("Provide a range of clients between 1 and #{clients.size}:") { |q| q.in("1-#{clients.size}") }

  if range_input.include?('-') || range_input.include?(':') || range_input.include?(' ')
    range = range_input.split(/[\s\-\:]/)
  else
    range = (1..range_input.to_i).to_a.map(&:to_s)
  end

  range_str = range.size == 1 ? range.first : "#{range.first} to #{range.last}"
  @logger.info("Range provided: #{range_str}".yellow) # Log the range provided
  
  range
end

# Get the number of days for file deletion.
def get_delete_days(prompt, default_days)
  specify_days = prompt.yes?("Specify the number of days to delete files (default: #{default_days} days)?")
  return default_days unless specify_days

  prompt.ask("Enter the number of days (1-30):") { |q| q.in('1-30') }.to_i
end

# Get range and delete days information
def get_prompt_information(prompt, clients, default_days = 30)
  range = get_range(prompt, clients)
  days = get_delete_days(prompt, default_days)

  @logger.info("\n")
  [days, range]
end