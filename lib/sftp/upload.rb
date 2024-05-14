# frozen_string_literal: true

require_relative '../helpers/terminal_helpers'
require_relative '../helpers/file_helpers'
require_relative '../console_utils'
require_relative 'prompt'
require_relative 'sftp'
require_relative 'file_entry'

class SFTPUploader
  include InternalLogMethods

  attr_reader :argv

  def initialize
    @session = SFTP.new(ENV['HOST'], ENV['USERNAME'], ENV['PASSWORD'])
    @prompt  = TTY::Prompt.new
    @argv    = ARGV
    @logger  = Logger.new($stdout)
    @logger.formatter = proc { |_sev, _dt, _pn, msg| "#{msg}\n" }

    get_user_input
  end

  # Retrieves user input and assigns the values returned
  def get_user_input
    prompt_info = get_prompt_info(@prompt, @logger)
    assign_user_input(prompt_info)
  end

  # Assigns user input values
  def assign_user_input(prompt_info)
    @directory = prompt_info[:source_location]
    @clients   = prompt_info[:clients]
    @range     = prompt_info[:range]
    @days      = prompt_info[:days]
  end

  def run
    loop do
      clear_console
      process_clients
      break unless continue_processing_clients?(@prompt)

      reset_user_input
    end
    # Log server connection close once breaking out of loop
    @logger.info("\nServer connection closed".yellow)
  end
  
  private

  # Reset input if user opts to re-run the program.
  def reset_user_input
    @argv = [@argv.first]
    get_user_input
  end

  def process_clients
    @argv.concat(@range) if @range

    clients_to_cycle(@clients).each_with_index do |(client, remote_location), index|
      print_client_details(index, client, remote_location)
      next if remote_location.empty?

      process_client_files(remote_location, client, @days)
    end
  end

  def process_client_files(remote_location, client, days)
    if !analysis_mode?
      remove_old_files(@session, remote_location, client, days)
      upload_files(remote_location, client)
    end

    # Analyze remote files
    analyze_remote_entries(remote_location, client)

    increment_client_count
  end

  def increment_client_count
    @session.increment_clients_count
  end

  def arguments?
    @argv.any?
  end

  def analysis_mode?
    @argv.first == 'analyze'
  end

  def clear_console
    ConsoleUtils.clear_console_screen
  end

  # Returns a Filtered client list based on the given arguments.
  def clients_to_cycle(client_list)
    second_arg, third_arg = @argv[1..2]

    return client_list unless arguments? && second_arg
    return client_list.take(second_arg.to_i) if third_arg.nil?

    # Range for both analysis and upload mode.
    first = second_arg.to_i.pred
    second = third_arg.to_i

    client_list.to_a[first...second]
  end

  def analyze_remote_entries(remote_location, client)
    files_to_delete = []
  
    @session.entries(remote_location) do |entry|
      next if hidden_file?(entry.name)
  
      file_entry = FileEntry.new(entry, client)
      handle_file(file_entry, files_to_delete)
    end
  
    if files_to_delete.empty?
      @logger.info("\n")
      return
    end
  
    handle_files_to_delete(files_to_delete, remote_location)
  end

  def handle_file(file_entry, files_to_delete)
    if file_entry.directory?
      @logger.info("#{file_entry.entry.longname} ----- FOLDER".cyan)
    elsif file_entry.entry.attributes.size.nil? || file_entry.entry.attributes.size <= 0
      @logger.info("#{file_entry.entry.longname} #{file_entry.file_size_kb}" << ' ----- FILE SIZE ISSUE'.red)
      files_to_delete << file_entry.entry
    elsif !client_file?(file_entry.entry.name, file_entry.client)
      @logger.info(file_entry.entry.longname.to_s << ' ----- FILE DOES NOT BELONG HERE'.red)
      files_to_delete << file_entry.entry
    elsif recent_file?(file_entry.entry) && client_file?(file_entry.entry.name, file_entry.client)
      log_file_info(file_entry)
    else
      log_file_info(file_entry, false)
    end
  end

  def handle_files_to_delete(files_to_delete, remote_location)
    if !@prompt.yes?("\nDo you want to delete all files highlighted in red?")
      @logger.info("\n")
      return
    end

    files_to_delete.each do |file|
      remove_file_from_location(@session, remote_location, file)
      @logger.info("#{file.longname} ----- DELETED".red)
    end

    @logger.info("\nSuccessfully deleted #{files_to_delete.size} file(s).\n".green)
  end
  
  def log_file_info(file_entry, recent = true)
    file_name = recent ? file_entry.entry.longname.green : file_entry.entry.longname
    file_size = if file_entry.file_size_mb
      "#{file_entry.file_size_kb} (#{file_entry.file_size_mb})"
    else
      "#{file_entry.file_size_kb}"
    end
    @logger.info("#{file_name} #{file_size}")
  end

  # Returns a list of files in the directory that contain the specified client name, case-insensitive.
  def matching_files(client)
    Dir.children(@directory).select { |file| file.downcase.include?(client.downcase) }
  end

  def print_client_details(index, client, remote_location)
    start_point, end_point = @argv[1..2]

    index += if end_point
              start_point.to_i
            else
              1
            end

    print_formatted_details(format_client_details(index, client, remote_location))
  end

  def format_client_details(index, client, remote_location)
    formatted = "[#{index}: #{client}] #{remote_location}\n"
    formatted.yellow
  end

  def print_formatted_details(formatted_details)
    @logger.info(formatted_details)
  end

  def upload_files(remote_location, client)
    matches = matching_files(client)
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