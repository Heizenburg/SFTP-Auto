# frozen_string_literal: true

require_relative '../helpers/terminal_helpers'
require_relative '../console_utils'
require_relative 'sftp'
require_relative 'file_entry'
require_relative 'file_analyzer'
require_relative 'file_processor'
require_relative 'user_input_handler'
require_relative 'logger_wrapper'

require 'io/console'

class SFTPUploader
  ESC_KEY = 27

  def initialize
    @session = SFTP.new(ENV['HOST'], ENV['USERNAME'], ENV['PASSWORD'])
    @prompt = TTY::Prompt.new
    @logger = Logger.new($stdout)
    @argv = ARGV
    
    @logger.formatter = proc { |_sev, _dt, _pn, msg| "#{msg}\n" }
    @input_handler = UserInputHandler.new(@prompt, @logger)
    
    @running = true
    start_key_listener

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
      break unless @running 
      
      clear_console
      process_clients
      call_out_clients_with_unusual_file_counts
      
      break unless continue_processing_clients?
      
      clear_console
      reset_user_input
    end
  
    @logger.info("\nProgram ended due to escape key press") unless @running
    @logger.info("\nServer connection closed".yellow)
  end

  private

  def reset_user_input
    @argv = [@argv.first]
    get_user_input
  end

  def process_clients
    @argv.concat(@range) if @range
    @clients_with_recent_file_count = {}
  
    clients_to_cycle(@clients).each_with_index do |(client, remote_location), index|
      print_client_details(index, client, remote_location)
      next if remote_location.nil? || remote_location.empty?
  
      recent_file_count = @file_processor.process_client_files(remote_location, client, @days, analysis_mode?)
      
      # Store the recent file count along with the remote location and index
      @clients_with_recent_file_count[client] = {
        count: recent_file_count,
        remote_location: remote_location,
        index: index + 1
      }
      
      break unless @running
    end
  end
  
  def call_out_clients_with_unusual_file_counts
    clients_with_zero_recent_files = @clients_with_recent_file_count.select { |_, data| data[:count].zero? }
    clients_with_a_few_files = @clients_with_recent_file_count.select { |_, data| data[:count] < 20 && data[:count] > 0 }
  
    log_clients("Clients with no recent files (no files uploaded for the past week or more):", clients_with_zero_recent_files, :red) if clients_with_zero_recent_files.any?

    if clients_with_a_few_files.any? && @directory.include?('Shoprite')
      log_clients("Clients with a few recent files (less than 20 uploaded):", clients_with_a_few_files, :yellow) 
    end
  end

  # Extract info for each client and log it
  def log_clients(message, clients, color)
    @logger.info("#{message}\n")
    clients.each do |client, data|
      remote_location, index = data[:remote_location], data[:index]
      
      @logger.info("[#{index}: #{client}] #{remote_location}: #{data[:count]}".send(color))
    end
    @logger.info("\n")
  end
  
  def continue_processing_clients?
    return false unless @running
    
    user_continue_processing_clients?
  end

  def user_continue_processing_clients?
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
  
  def start_key_listener
    Thread.new do
      loop do
        break unless @running
        
        if IO.console.getch.ord == ESC_KEY
          @logger.info("\nEscape key pressed. Stopping the program...\n")
          @running = false
        end
        
        sleep(0.7)
      end
    end
  end
end
