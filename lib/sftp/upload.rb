# frozen_string_literal: true

require_relative '../helpers/terminal_helpers'
require_relative '../helpers/file_helpers'
require_relative '../console_utils'
require_relative 'prompt'
require_relative 'sftp'
require_relative 'file_entry'
require_relative 'user_input_handler'
require_relative 'client_processor'
require_relative 'logger_wrapper'

class SFTPUploader
  attr_reader :argv

  def initialize
    @session = SFTP.new(ENV['HOST'], ENV['USERNAME'], ENV['PASSWORD'])
    @prompt  = TTY::Prompt.new
    @argv    = ARGV
    @logger  = LoggerWrapper.new($stdout)
    @user_input_handler = UserInputHandler.new(@prompt, @logger)
    
    get_user_input
  end

  def get_user_input
    prompt_info = @user_input_handler.get_prompt_info
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
      ConsoleUtils.clear_console_screen
      process_clients
      break unless @user_input_handler.continue_processing_clients?

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
    client_processor = ClientProcessor.new(@session, @logger, @directory, @days, analysis_mode?, @argv)

    client_processor.process(@clients)
  end

  def analysis_mode?
    @argv.first == 'analyze'
  end
end
