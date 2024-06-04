class FileAnalyzer

  # Number of days files are considered to be recent
  DAYS_LIMIT = 6 

  def initialize(session, logger, prompt)
    @session = session
    @logger = logger
    @prompt = prompt
  end

  def analyze(remote_location, client)
    files_to_delete = []

    @session.entries(remote_location) do |entry|
      next if hidden_file?(entry.name)

      file_entry = FileEntry.new(entry, client)
      handle_file(file_entry, files_to_delete)

    end
    @logger.info("\n")

    handle_files_to_delete(files_to_delete, remote_location) unless files_to_delete.empty?
  end

  private

  def handle_file(file_entry, files_to_delete)
    if file_entry.directory?
      @logger.info("#{file_entry.entry.longname} ----- FOLDER".cyan)
    elsif file_entry.entry.attributes.size.nil? || file_entry.entry.attributes.size <= 0
      @logger.info("#{file_entry.entry.longname} #{file_entry.file_size_kb} ----- FILE SIZE ISSUE".red)
      files_to_delete << file_entry.entry
    elsif !client_file?(file_entry.entry.name, file_entry.client)
      @logger.info("#{file_entry.entry.longname} ----- FILE DOES NOT BELONG HERE".red)
      files_to_delete << file_entry.entry
    elsif recent_file?(file_entry.entry) && client_file?(file_entry.entry.name, file_entry.client)
      log_file_info(file_entry)
    else
      log_file_info(file_entry, false)
    end
  end

  def handle_files_to_delete(files_to_delete, remote_location)
    return unless @prompt.yes?("\nDo you want to delete all files highlighted in red?")

    files_to_delete.each do |file|
      remove_file_from_location(remote_location, file)
      @logger.info("#{file.longname} ----- DELETED".red)
    end

    @logger.info("\nSuccessfully deleted #{files_to_delete.size} file(s).\n".green)
  end

  def remove_file_from_location(remote_location, file)
    @session.remove!(File.join(remote_location.slice(1, remote_location.size), file.name))
  end

  def hidden_file?(file)
    file.start_with?('.')
  end

  def client_file?(file, client)
    file.downcase.include?(client.downcase)
  end

  def recent_file?(file)
    file_mtime = if file.respond_to?(:attributes) && file.attributes.respond_to?(:mtime)
                  Time.at(file.attributes.mtime)
                else
                  File.mtime(file)
                end
    file_mtime > (Time.now - DAYS_LIMIT.days)
  end

  def log_file_info(file_entry, recent = true)
    file_name = recent ? file_entry.entry.longname.green : file_entry.entry.longname
    file_size = if file_entry.file_size_mb
                  "#{file_entry.file_size_kb} (#{file_entry.file_size_mb})"
                else
                  "#{file_entry.file_size_kb}"
                end
    @logger.info("#{file_name} #{file_size}")
  end
end
