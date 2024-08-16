class FileAnalyzer
  # Number of days files are considered to be recent
  DAYS_LIMIT = 6

  def initialize(session, logger, prompt)
    @session = session
    @logger = logger
    @prompt = prompt
    @recent_file_count = 0
  end

  def analyze(remote_location, client)
    files_to_delete = []

    @session.entries(remote_location) do |entry|
      next if hidden_file?(entry.name)

      file_entry = FileEntry.new(entry, client)
      process_file(file_entry, files_to_delete)
    end

    @logger.info("\n")
    handle_files_to_delete(files_to_delete, remote_location) unless files_to_delete.empty?
    log_recent_files_count
  end

  def recent_file_count
    @recent_file_count
  end

  private

  def process_file(file_entry, files_to_delete)
    case
    when file_entry.directory?
      log_directory(file_entry)
    when file_size_invalid?(file_entry)
      log_file_size_issue(file_entry, files_to_delete)
    when !client_file?(file_entry.entry.name, file_entry.client)
      log_file_not_belonging(file_entry, files_to_delete)
    when recent_file?(file_entry.entry) && client_file?(file_entry.entry.name, file_entry.client)
      log_file_info(file_entry)
    else
      log_file_info(file_entry, false)
    end
  end

  def log_directory(file_entry)
    @logger.info("#{file_entry.entry.longname} ----- FOLDER".cyan)
  end

  def file_size_invalid?(file_entry)
    file_entry.entry.attributes.size.nil? || file_entry.entry.attributes.size <= 0
  end

  def log_file_size_issue(file_entry, files_to_delete)
    @logger.info("#{file_entry.entry.longname} #{file_entry.file_size_kb} ----- FILE SIZE ISSUE".red)
    files_to_delete << file_entry.entry
  end

  def log_file_not_belonging(file_entry, files_to_delete)
    @logger.info("#{file_entry.entry.longname} ----- FILE DOES NOT BELONG HERE".red)
    files_to_delete << file_entry.entry
  end

  def log_recent_files_count
    count_message = @recent_file_count.zero? ? " #{@recent_file_count}\n" : " #{@recent_file_count}\n".green
    @logger.info("Recent files count" << count_message)
  end

  def handle_files_to_delete(files_to_delete, remote_location)
    return unless @prompt.yes?("Do you want to delete all files highlighted in red?")

    @logger.info("\n")
    files_to_delete.each do |file|
      remove_file_from_location(remote_location, file)
      @logger.info("#{file.longname} ----- DELETED".red)
    end

    @logger.info("\nSuccessfully deleted #{files_to_delete.size} file(s).\n".green)
  end

  def remove_file_from_location(remote_location, file)
    @session.remove!(File.join(remote_location.slice(1..-1), file.name))
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
    file_size = file_entry.file_size_mb ? "#{file_entry.file_size_kb} (#{file_entry.file_size_mb})" : "#{file_entry.file_size_kb}"
    
    @logger.info("#{file_name} #{file_size}")
    @recent_file_count += 1 if recent
  end
end