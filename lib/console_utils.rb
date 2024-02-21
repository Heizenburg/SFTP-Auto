# frozen_string_literal: true

require 'tty-font'

module ConsoleUtils
  def self.clear_console_screen
    if Gem.win_platform?
      system('cls') # Windows
    else
      system('clear') # Unix-based systems
    end
  end

  def self.display_message(logger, message)
    font = TTY::Font.new(:starwars)
    message = font.write(message, letter_spacing: 0.5)

    logger.info(message.to_s)
  end
end