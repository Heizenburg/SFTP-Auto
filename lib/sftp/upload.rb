# frozen_string_literal: true

require_relative '../helpers/terminal_helpers'
require_relative '../console_utils'
require_relative 'sftp'
require_relative 'file_entry'
require_relative 'file_analyzer'
require_relative 'file_processor'
require_relative 'user_input_handler'
require_relative 'logger_wrapper'

class SFTPUploader
  def initialize
    @session = SFTP.new(ENV['HOST'], ENV['USERNAME'], ENV['PASSWORD'])
    @prompt = TTY::Prompt.new
    @logger = Logger.new($stdout)
    @argv = ARGV
    @logger.formatter = proc { |_sev, _dt, _pn, msg| "#{msg}\n" }
    @input_handler = UserInputHandler.new(@prompt, @logger)
    
    get_user_input
    @file_processor = FileProcessor.new(@session, @logger, @directory)
  end

  def get_user_input
    prompt_info = @input_handler.get_prompt_info
    assign_user_input(prompt_info)
  end

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
      break unless continue_processing_clients?

      reset_user_input
    end
    @logger.info("\nServer connection closed".yellow)
  end

  private

  def reset_user_input
    @argv = [@argv.first]
    get_user_input
  end

  def process_clients
    @argv.concat(@range) if @range

    clients_to_cycle(@clients).each_with_index do |(client, remote_location), index|
      print_client_details(index, client, remote_location)
      next if remote_location.empty?

      @file_processor.process_client_files(remote_location, client, @days, analysis_mode?)
    end
  end

  def continue_processing_clients?
    @prompt.yes?("Continue #{analysis_mode? ? 'analyzing' : 'uploading'} clients?")
  end

  def analysis_mode?
    @argv.first == 'analyze'
  end

  def clear_console
    ConsoleUtils.clear_console_screen
  end

  def clients_to_cycle(client_list)
    second_arg, third_arg = @argv[1..2]
    return client_list unless @argv.any? && second_arg
    return client_list.take(second_arg.to_i) if third_arg.nil?

    first = second_arg.to_i.pred
    second = third_arg.to_i
    client_list.to_a[first...second]
  end

  def print_client_details(index, client, remote_location)
    start_point, end_point = @argv[1..2]
    index += end_point ? start_point.to_i : 1
    @logger.info(format_client_details(index, client, remote_location))
  end

  def format_client_details(index, client, remote_location)
    formatted = "[#{index}: #{client}] #{remote_location}\n"
    formatted.yellow
  end
end