# frozen_string_literal: true

class String
  # Colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end
end

class Integer
  # Dates helper
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

  def months
    self * 30.days
  end

  def years
    self * 12.months
  end
end
