# frozen_string_literal: true

require 'tty-font'

module Message
  def self.display_message(logger, message)
    font = TTY::Font.new(:starwars)
    message = font.write(message, letter_spacing: 0.5)

    logger.info(message.to_s)
  end
end
