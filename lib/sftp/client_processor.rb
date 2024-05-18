class ClientProcessor
  def initialize(session, logger, directory, days, analysis_mode, argv)
    @session = session
    @logger = logger
    @directory = directory
    @days = days
    @analysis_mode = analysis_mode
    @argv = argv
  end

  def process(clients)
    clients_to_cycle(clients).each_with_index do |(client, remote_location), index|
      print_client_details(index, client, remote_location)
      next if remote_location.empty?

      process_client_files(remote_location, client)
    end
  end

  private

  def process_client_files(remote_location, client)
    file_processor = FileProcessor.new(@session, @logger, @directory, client, @days, @analysis_mode)
    file_processor.process_files(remote_location)
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
    @logger.info("[#{index}: #{client}] #{remote_location}\n".yellow)
  end
end
