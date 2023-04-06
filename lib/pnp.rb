require_relative 'helpers/terminal_helpers'
require_relative 'helpers/file_helpers'

location = 'R:/RawData/PNP SAP/Client File Downloads/'

def list_child_dirs_files(parent_directory)
  Dir.glob("#{parent_directory}**/*", File::FNM_DOTMATCH).each do |file|
    next if File.directory?(file) || File.basename(file) == '.' || File.basename(file) == '..' || !recent_file?(file)
    puts "#{file} (#{File.mtime(file)})"
    puts "\n"
  end
end

list_child_dirs_files(location)