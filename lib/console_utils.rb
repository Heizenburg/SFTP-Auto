module ConsoleUtils
  def self.clear_console_screen
    if Gem.win_platform? # Check if the platform is Windows
      system('cls') # Clear the console screen for Windows
    else
      system('clear') # Clear the console screen for Unix-based systems
    end
  end
end
