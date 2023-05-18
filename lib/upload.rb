  # frozen_string_literal: true

  require 'yaml'

  require_relative 'helpers/terminal_helpers'
  require_relative 'helpers/file_helpers'
  require_relative 'sftp'

  include InternalLogMethods

  # Load the list of clients from a YAML file.
  clients = YAML.load_file('lib/shoprite_clients.yml')

  def arguments?
    ARGV.any?
  end

  def analysis_mode?
    ARGV.at(0) == 'analyze'
  end

  def clients_to_cycle(client_list)
    return client_list if ARGV.empty?
    first_arg, second_arg, third_arg = ARGV

    return client_list.cycle.take(first_arg.to_i) if arguments? && !analysis_mode?
    return client_list.take(second_arg.to_i) if arguments? && analysis_mode? && second_arg && third_arg.nil?

    # Range when you are not on upload mode.
    if arguments? && analysis_mode? && second_arg && third_arg
      first = second_arg.to_i.pred
      second = third_arg.to_i

      cycle = client_list.to_a[first...second]
      return cycle
    end

    client_list
  end

  # Print files in remote directory.
  def print_remote_entries(session, remote_location, client)
    session.entries(remote_location) do |entry|
      next unless not_hidden_file?(entry.name)
  
      if entry.attributes.directory?
        puts "#{entry.longname} ----- FOLDER".blue
        next
      end
  
      if file_extention?(entry.name, '.csv')
        puts "#{entry.longname} ----- MANUAL EXTRACTION"
        next
      end
  
      if recent_file?(entry) && client_file?(entry.name, client)
        puts "#{entry.longname.green} #{convert_bytes_to_kilobytes(entry.attributes.size)}"
        next
      end
  
      if recent_file?(entry) && !client_file?(entry.name, client)
        puts "#{entry.longname.green} ----- NEW FILE DOES NOT BELONG HERE".red
        remove_file_from_location(session, remote_location, entry)
        puts "#{entry.longname.green} ----- DELETED".red
        next
      end
  
      if !recent_file?(entry) && !client_file?(entry.name, client)
        puts "#{entry.longname.to_s} ----- FILE DOES NOT BELONG HERE\n".red
        remove_file_from_location(session, remote_location, entry)
        puts "#{entry.longname} ----- DELETED".red
        next
      end
  
      if client_file?(entry.name, client) && !recent_file?(entry)
        puts "#{entry.longname} #{convert_bytes_to_kilobytes(entry.attributes.size)}"
      end
    end
  
    puts "\n"
  end

  # Get all files with the client name (prefix).
  def get_matching_files(local, client)
    Dir.children(local).select do |file|
      (file =~ /(#{client}).*.zip$/i) && not_hidden_file?(file)
    end
  end

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

  def print_client_information(index, client, remote_location)
    _, start_point, end_point = ARGV
    end_point ? index += start_point.to_i : index += 1 

    puts "[#{index}: #{client}] #{remote_location}\n".yellow
  end

  # Uploads file to specified remote location. 
  def upload_file(session, file, local, remote_location, index, matches)
    spinner = TTY::Spinner.new(
      "[:spinner] Copying #{file} to #{remote_location} -- (#{index.next}/#{matches.size})",
      success_mark: '+',
      clear: true
    )
    spinner.auto_spin

    begin
      session.upload("#{local}/#{file}", "#{remote_location}/#{file}")
      spinner.success
    rescue StandardError => e
      log_error("Error while uploading #{file}: #{e}".red)
    end
  end

  def main(local_directory, clients)
    # Check if the user has specified a local directory.
    log_error('Error: local directory is not specified.'.red) if local_directory.nil?

    # Create a new SFTP session.
    session = SFTP.new(ENV['HOST'], ENV['USERNAME'], '@Cellz911$#@')

    # Get the user's input.
    prompt = TTY::Prompt.new

    days, range = get_prompt_information(prompt, clients)
    ARGV.concat(range) if range

    clients_to_cycle(clients).each_with_index do |(client, remote_location), index|
      matches = get_matching_files(local_directory, client)
      print_client_information(index, client, remote_location)

      next if matches.compact.empty? 

      matches.compact.each_with_index do |file, index|
        next if analysis_mode?
        upload_file(session, file, local_directory, remote_location, index, matches) unless remote_location.empty? 
      end

      session.increment_clients_count
      delete_files(session, remote_location, days)

      unless remote_location.empty? 
        print_remote_entries(session, remote_location, client)
      end
    end
  end

  local = ENV['LOCAL_LOCATION']
  main(local, clients)
