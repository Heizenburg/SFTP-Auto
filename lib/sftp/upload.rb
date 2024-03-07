# frozen_string_literal: true

require_relative '../helpers/terminal_helpers'
require_relative '../helpers/file_helpers'
require_relative '../console_utils'
require_relative 'prompt'
require_relative 'sftp'

class SFTPUploader
  include InternalLogMethods

  attr_reader :argv

  def initialize
    @session = SFTP.new(ENV['HOST'], ENV['USERNAME'], ENV['PASSWORD'])
    @prompt  = TTY::Prompt.new
    @argv    = ARGV
    @logger  = Logger.new($stdout)
    @logger.formatter = proc { |_severity, _datetime, _progname, msg| "#{msg}\n" }

    get_user_input
  end

  def get_user_input
    @days, @range, @clients, @directory = get_prompt_information(@prompt, @logger)
  end

  def run
    loop do
      clear_console
      process_clients
      unless process_clients_again?(@prompt)
        @logger.info("\nServer connection closed".yellow)

        break
      end

      @argv = [@argv.first] # Reset ARGV if user opts to re-run the program.
      get_user_input
    end
  end

  private

  def process_clients
    @argv.concat(@range) if @range

    clients_to_cycle(@clients).each_with_index do |(client, remote_location), index|
      print_client_details(index, client, remote_location)
      next if remote_location.empty?

      process_client_files(remote_location, client, @days)
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

  def analysis_mode?
    @argv.first == 'analyze'
  end

  def clear_console
    ConsoleUtils.clear_console_screen
  end

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

      file_size = entry.attributes.size
      file_size_kb = convert_bytes(file_size, :KB)
      file_size_mb = convert_bytes(file_size, :MB)

      if entry.attributes.directory?
        @logger.info("#{entry.longname} ----- FOLDER".cyan)
        next
      end

      if recent_file?(entry) && client_file?(entry.name, client)
        if file_size_mb
          @logger.info("#{entry.longname.green} #{file_size_kb} (#{file_size_mb})")
        else
          @logger.info("#{entry.longname.green} #{file_size_kb}")
        end
        next
      end

      unless client_file?(entry.name, client)
        @logger.info(entry.longname.to_s << ' ----- FILE DOES NOT BELONG HERE'.red)
        files_to_delete << entry
      end

      if client_file?(entry.name, client) && !recent_file?(entry)
        if file_size_mb
          @logger.info("#{entry.longname} #{file_size_kb} (#{file_size_mb})")
        else
          @logger.info("#{entry.longname} #{file_size_kb}")
        end
      end
    end

    if files_to_delete.empty?
      @logger.info("\n")
      return 
    end

    if !@prompt.yes?("\nDo you want to delete all files that do not belong to the client?")
      @logger.info("\nNo files were deleted.".green)
      return
    end
    
    files_to_delete.each do |file|
      remove_file_from_location(@session, remote_location, file)
      @logger.info("#{file.longname} ----- DELETED".red)
    end
    
    @logger.info("\nSuccessfully deleted #{files_to_delete.size} files not belonging to the client.\n".green)
  end

  def get_matching_files(client)
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
