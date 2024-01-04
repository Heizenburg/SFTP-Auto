# frozen_string_literal: true

require_relative '../helpers/terminal_helpers'
require_relative '../helpers/file_helpers'
require_relative 'prompt'
require_relative 'sftp'

class SFTPUploader
  include InternalLogMethods

  attr_reader :argv

  def initialize(directory, clients)
    @directory = directory
    @clients   = clients
    @session   = SFTP.new(ENV['HOST'], ENV['USERNAME'])
    @prompt    = TTY::Prompt.new
    @argv      = ARGV
    @logger    = Logger.new(STDOUT)

    @logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
  end

  def run
    validate_local_directory
    process_clients
  end

  private

  def validate_local_directory
    raise 'Error: local directory is not specified.' unless @directory
  end

  def process_clients
    days, range = get_prompt_information(@prompt, @clients, @logger)
    @argv.concat(range) if range

    clients_to_cycle(@clients).each_with_index do |(client, remote_location), index|
      print_client_details(index, client, remote_location)
      next if remote_location.empty?

      process_client_files(remote_location, client, days)
    end
  end

  def process_client_files(remote_location, client, days)
    unless analysis_mode?
      remove_old_files(@session, remote_location, client, days)
      upload_files(remote_location, client) 
    end

    analyze_remote_entries(remote_location, client)
    increment_client_count
  end

  def increment_client_count
    @session.increment_clients_count
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

  def analyze_remote_entries(remote_location, client)
    @session.entries(remote_location) do |entry|
      next unless not_hidden_file?(entry.name)

      if entry.attributes.directory?
        @logger.info("#{entry.longname} ----- FOLDER".cyan)
        next
      end

      if recent_file?(entry) && client_file?(entry.name, client)
        @logger.info("#{entry.longname.green} #{convert_bytes_to_kilobytes(entry.attributes.size)}")
        next
      end

      unless client_file?(entry.name, client)
        @logger.info("#{entry.longname} ----- FILE DOES NOT BELONG HERE\n")
        remove_file_from_location(@session, remote_location, entry)
        @logger.info("#{entry.longname} ----- DELETED".red)
        next
      end

      if client_file?(entry.name, client) && !recent_file?(entry)
        @logger.info("#{entry.longname} #{convert_bytes_to_kilobytes(entry.attributes.size)}")
      end
    end

    @logger.info("\n")
  end

  def get_matching_files(client)
    Dir.children(@directory).select { |file| file =~ /^.*#{client}.*\..+$/i }
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
    @logger.info(formatted_details)
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
      @session.upload("#{@directory}/#{file}", "#{remote_location}/#{file}")
      spinner.success
    rescue StandardError => e
      handle_upload_error(file, e)
    end
  end

  def handle_upload_error(file, error)
    @logger.error("Error while uploading #{file}: #{error.message}".red)
    @logger.error(error.backtrace.join("\n"))
  end
end