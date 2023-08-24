# frozen_string_literal: true

require_relative '../helpers/terminal_helpers'
require_relative '../helpers/file_helpers'
require_relative 'prompt'
require_relative 'sftp'

class SFTPUploader
  include InternalLogMethods

  def initialize(local_directory, clients)
    @local_directory = local_directory
    @clients = clients
    @session = SFTP.new(ENV['HOST'], ENV['USERNAME'])
    @prompt = TTY::Prompt.new
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
    ARGV.concat(range) if range

    clients_to_cycle.each_with_index do |(client, remote_location), index|
      print_client_details(index, client, remote_location)
      next if remote_location.empty?

      if analysis_mode?
        print_remote_entries(remote_location, client)
      else
        upload_files(remote_location, client)
        @session.increment_clients_count
        delete_files(remote_location, days)
        print_remote_entries(remote_location, client)
      end
    end
  end

  def clients_to_cycle
    first_arg, second_arg, third_arg = ARGV

    return @clients if ARGV.empty? || !second_arg

    if third_arg.nil?
      return @clients.take(second_arg.to_i)
    end

    first = second_arg.to_i.pred
    second = third_arg.to_i

    @clients[first...second]
  end

  def analysis_mode?
    ARGV.first == 'analyze'
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
    mode, *args = ARGV
  
    if args.size == 2
      start_point, end_point = args
      index += start_point.to_i if end_point
    else
      index += 1
    end
  
    puts "[#{index}: #{client}] #{remote_location}\n".yellow
  end

  def upload_files(remote_location, client)
    matches = get_matching_files(client)
    matches.compact.each_with_index do |file, index|
      upload_file(file, remote_location, index, matches.size)
    end
  end

  def upload_file(file, remote_location, index, total_files)
    spinner = TTY::Spinner.new(
      "[:spinner] Copying #{file} to #{remote_location} -- (#{index.next}/#{total_files})",
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

