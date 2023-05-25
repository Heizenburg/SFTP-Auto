def get_range(prompt, clients)
  range_answer = prompt.yes?("Do you want to provide a range?")
  return nil unless range_answer

  range = prompt.ask("Provide a range of clients between 1 and #{clients.size}:") { |q| q.in("1-#{clients.size}") }
  # Split range by either space or a hyphen. 
  range.split(/[\s\-]/) 
end

def get_delete_days(prompt, default_days)
  delete_answer = prompt.yes?("Do you want to specify the number of days for a file to be deleted? (default: #{default_days} days)")
  return default_days unless delete_answer

  prompt.ask("Enter the amount of days?") { |q| q.in('1-60') }.to_i
end

def get_prompt_information(prompt, clients, default_days = 30)
  range = get_range(prompt, clients) 
  days  = get_delete_days(prompt, default_days)

  puts "\n"
  [days, range]
end