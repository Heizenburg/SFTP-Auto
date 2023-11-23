require 'benchmark'
require 'yaml'
require 'dotenv/load'
require 'pry'
require 'pry-nav'
require 'pry-remote'

# Define the two methods
def remove_file_from_location_v1(remote_location, file)
  File.join(remote_location[1..-1], file.name)
end

def remove_file_from_location_v2(remote_location, file)
  File.join(remote_location.drop(1), file.name)
end

# Create sample data
remote_location = ['root', 'folder1', 'folder2', 'folder3']
file = OpenStruct.new(name: 'file.txt')

time_v1 = Benchmark.realtime do
  1_000_000.times do
    remove_file_from_location_v1(remote_location, file)
  end
end

puts "Time taken for method with [1..-1]: #{time_v1} seconds"

time_v2 = Benchmark.realtime do
  1_000_000.times do
    remove_file_from_location_v2(remote_location, file)
  end
end

puts "Time taken for method with drop(1): #{time_v2} seconds"

def get_matching_files_entries(local, client)
  pattern = Regexp.new("(#{client}).*\\.(\\w+)$", Regexp::IGNORECASE)
  Dir.entries(local).select do |file|
    file.match(pattern)
  end
end

def get_matching_files_glob(local, client)
  pattern = Regexp.new("(#{client}).*\\.(\\w+)$", Regexp::IGNORECASE)
  Dir.glob("#{local}").select do |file|
    file.match(pattern)
  end
end

def get_matching_files_dir(local, client)
  Dir.children(local).select do |file|
    file =~ /(#{client}).*\.\w+$/i
  end
end

def get_matching_files_includes(local, client)
  Dir.children(local).select do |file|
    File.file?(file) && file.downcase.include?(client.downcase) 
  end
end

# Load the list of clients from a YAML file and take the first five.
clients = YAML.load_file('lib/shoprite_clients.yml').take(5)
local = ENV['LOCAL_LOCATION']

Benchmark.bm do |x|
  x.report('Dir.entries') { clients.each { |client| get_matching_files_entries(local, client) } }
  x.report('Dir.glob') { clients.each { |client| get_matching_files_glob(local, client) } }
  x.report('Dir.children - regex') { clients.each { |client| get_matching_files_dir(local, client) } }
  x.report('Dir.children - include?') { clients.each { |client| get_matching_files_includes(local, client) } }
end