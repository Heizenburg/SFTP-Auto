# frozen_string_literal: true

require_relative '../helpers/terminal_helpers'
require_relative '../helpers/file_helpers'
require_relative 'prompt'
require_relative 'sftp'

class SFTPUploader
  include InternalLogMethods

  attr_reader :argv

  def initialize(local_directory, clients)
    @local_directory = local_directory
    @clients         = clients
    @session         = SFTP.new(ENV['HOST'], ENV['USERNAME'], "@Cellz911$@#")
    @prompt          = TTY::Prompt.new
    @argv            = ARGV
  end

  def run
    validate_local_directory
    process_clients
  end

  private

  def validate_local_directory
    raise 'Error: local directory is not specified.' unless @local_directory
  end

  def process_clients
    days, range = get_prompt_information(@prompt, @clients)
    @argv.concat(range) if range

    clients_to_cycle(@clients).each_with_index do |(client, remote_location), index|
      print_client_details(index, client, remote_location)
      next if remote_location.empty?

      if analysis_mode?
        print_remote_entries(remote_location, client)
      else
        upload_files(remote_location, client)
        # Delete files that are older than days specified.
        delete_files(@session, remote_location, days)
        print_remote_entries(remote_location, client)
        @session.increment_clients_count
      end
    end
  end

  def arguments?
    @argv.any?
  end

  def clients_to_cycle(client_list)
    first_arg, second_arg, third_arg = @argv
  
    return client_list unless arguments? && second_arg
    return client_list.take(second_arg.to_i) if third_arg.nil?
  
    # Range for both analysis and upload mode.
    first = second_arg.to_i.pred
    second = third_arg.to_i
  
    client_list.to_a[first...second]
  end

  def analysis_mode?
    @argv.first == 'analyze'
  end

  def print_remote_entries(remote_location, client)
    @session.entries(remote_location) do |entry|
      next unless not_hidden_file?(entry.name)

      if entry.attributes.directory?
        puts "#{entry.longname} ----- FOLDER".blue
        next
      end

      if recent_file?(entry) && client_file?(entry.name, client)
        puts "#{entry.longname.green} #{convert_bytes_to_kilobytes(entry.attributes.size)}"
        next
      end

      if !client_file?(entry.name, client)
        puts "#{entry.longname} ----- FILE DOES NOT BELONG HERE\n"
        remove_file_from_location(@session, remote_location, entry)
        puts "#{entry.longname} ----- DELETED".red
        next
      end

      if client_file?(entry.name, client) && !recent_file?(entry)
        puts "#{entry.longname} #{convert_bytes_to_kilobytes(entry.attributes.size)}"
      end
    end

    puts "\n"
  end

  def get_matching_files(client)
    Dir.children(@local_directory).select { |file| file =~ /^.*#{client}.*\..+$/i }
  end

  def print_client_details(index, client, remote_location)
    start_point, end_point = @argv[1..2]

    if end_point 
      index += start_point.to_i 
    else
      index += 1 
    end

    print_formatted_details(format_client_details(index, client, remote_location))
  end

  def format_client_details(index, client, remote_location)
    "[#{index}: #{client}] #{remote_location}\n".yellow
  end
  
  def print_formatted_details(formatted_details)
    puts formatted_details
  end

  def upload_files(remote_location, client)
    matches = get_matching_files(client)
    matches.compact.each_with_index do |file, index|
      upload_file(file, remote_location, index, matches.size)
    end
  end

  def upload_file(file, remote_location, index, total_files)
    spinner = TTY::Spinner.new(
      "[:spinner] Copying #{file.yellow} to #{remote_location.cyan} -- (#{index.next}/#{total_files})",
      success_mark: '+',
      clear: true
    )
    spinner.auto_spin

    begin
      @session.upload("#{@local_directory}/#{file}", "#{remote_location}/#{file}")
      spinner.success
    rescue StandardError => e
      log_error("Error while uploading #{file}: #{e}".red)
    end
  end
end

