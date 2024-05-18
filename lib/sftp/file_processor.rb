class FileProcessor
  def initialize(session, logger, directory, client, days, analysis_mode)
    @session = session
    @logger = logger
    @directory = directory
    @client = client
    @days = days
    @analysis_mode = analysis_mode
  end

  def process_files(remote_location)
    unless @analysis_mode
      remove_old_files(remote_location)
      upload_files(remote_location)
    end

    analyze_remote_entries(remote_location)
  end

  private

  def remove_old_files(remote_location)
    files_to_delete = @session.dir.entries(remote_location).select do |file|
      file.file? && Time.at(file.attributes.mtime) < (Time.now - @days * 24 * 60 * 60)
    end

    return if files_to_delete.empty?

    files_to_delete.each do |file|
      delete_spinner = TTY::Spinner.new(
        "[:spinner] Deleting #{file.name} from #{remote_location}",
        success_mark: '-',
        clear: true
      )
      delete_spinner.auto_spin

      begin
        remove_file_from_location(remote_location, file)
        delete_spinner.success
        @logger.info("Removed: #{file.longname} #{convert_bytes(file.attributes.size)} -- OLDER THAN #{@days} DAYS ".red)
      rescue StandardError => e
        log_error("Error deleting file #{file.name}: #{e}".red)
      end
    end
    @logger.info("\n")
  end

  def remove_file_from_location(remote_location, file)
    @session.remove!(File.join(remote_location.slice(1, remote_location.size), file.name))
  end

  def upload_files(remote_location)
    matches = matching_files
    matches.compact.each_with_index do |file, index|
      upload_file(file, remote_location, index, matches.size)
    end
  end

  def matching_files
    Dir.children(@directory).select { |file| file.downcase.include?(@client.downcase) }
  end

  def upload_file(file, remote_location, index, total_files)
    spinner = TTY::Spinner.new(
      "[:spinner] Copying #{file.yellow} to #{remote_location.cyan} -- (#{index.next}/#{total_files})",
      success_mark: '+',
      clear: true
    )
    spinner.auto_spin

    begin
      @session.upload("#{@directory}/#{file}", "#{remote_location}/#{file}")
      spinner.success
    rescue StandardError => e
      handle_upload_error(file, e)
    end
  end
