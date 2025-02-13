require 'logger'

class LoggerWrapper
  def initialize(output)
    @logger = Logger.new(output)
    @logger.formatter = proc { |_sev, _dt, _pn, msg| "#{msg}\n" }
  end

  def info(message)
    @logger.info(message)
  end

  def error(message)
    @logger.error(message)
  end
end
