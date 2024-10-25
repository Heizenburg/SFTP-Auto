# frozen_string_literal: true

require 'tty-font'

module ConsoleUtils
  def self.clear_console_screen
    if Gem.win_platform?
      system('cls')
    else
      system('clear')
    end
  end
end
