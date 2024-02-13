# frozen_string_literal: true

module ConsoleColors
  def self.colorize(color_code, text)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def self.red(text)
    colorize(31, text)
  end

  def self.green(text)
    colorize(32, text)
  end

  def self.yellow(text)
    colorize(33, text)
  end

  def self.blue(text)
    colorize(34, text)
  end

  def self.pink(text)
    colorize(35, text)
  end

  def self.cyan(text)
    colorize(36, text)
  end
end

module TimeHelper
  def minutes
    self * 60
  end

  def hours
    self * 60.minutes
  end

  def days
    self * 24.hours
  end

  def weeks
    self * 7.days
  end
end

class String
  include ConsoleColors

  def colorize(color_code)
    ConsoleColors.colorize(color_code, self)
  end
end

class Integer
  include TimeHelper
end