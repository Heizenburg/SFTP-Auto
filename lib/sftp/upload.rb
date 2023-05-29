  # frozen_string_literal: true

  require_relative '../helpers/terminal_helpers'
  require_relative '../helpers/file_helpers'
  require_relative 'prompt'
  require_relative 'sftp'

  include InternalLogMethods

  def arguments?
    ARGV.any?
  end

  def analysis_mode?
    ARGV.at(0) == 'analyze'
  end

  def clients_to_cycle(client_list)
    first_arg, second_arg, third_arg = ARGV

    if arguments? && second_arg && third_arg.nil?
      return client_list.take(second_arg.to_i) 
    end

    # Range when you are not on upload mode.
    if arguments? && second_arg && third_arg
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

      if recent_file?(entry) && client_file?(entry.name, client)
        puts "#{entry.longname.green} #{convert_bytes_to_kilobytes(entry.attributes.size)}"
        next
      end
  
      if !client_file?(entry.name, client) && !entry.name.end_with?('.csv')
        puts "#{entry.longname} ----- FILE DOES NOT BELONG HERE\n"
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
      (file =~ /(#{client}).*\.\w+$/i)
    end
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

  class SFTP::Upload
    def self.main(local_directory, clients)
      # Check if the user has specified a local directory.
      log_error('Error: local directory is not specified.'.red) if local_directory.nil?

      session = SFTP.new(ENV['HOST'], ENV['USERNAME'])
      prompt  = TTY::Prompt.new

      days, range = get_prompt_information(prompt, clients)
      ARGV.concat(range) if range

      clients_to_cycle(clients).each_with_index do |(client, remote_location), index|
        if analysis_mode?
          print_client_information(index, client, remote_location)
          print_remote_entries(session, remote_location, client) unless remote_location.empty?
          next
        end
        
        matches = get_matching_files(local_directory, client)
        print_client_information(index, client, remote_location)
        next if remote_location.empty?

        matches.compact.each_with_index do |file, index|
          upload_file(session, file, local_directory, remote_location, index, matches)
        end

        session.increment_clients_count
        delete_files(session, remote_location, days)
        print_remote_entries(session, remote_location, client)
      end
    end
  end
