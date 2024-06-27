require_relative '../lib/sftp/file_processor'
require_relative '../lib/sftp/file_analyzer'

require 'rspec'

describe FileProcessor do
  let(:session) { double }
  let(:logger) { double }
  let(:directory) { 'directory' }
  let(:file_processor) { FileProcessor.new(session, logger, directory) }

  describe '#process_client_files' do
    it 'calls remove_old_files and upload_files without analysis mode' do
      file_processor.process_client_files('remote_location', 'client', 5, false)
      expect(session).to receive(:dir).with('remote_location')
      expect(session).to receive(:remove!).with('remote_location/file')
      expect(session).to receive(:upload).with("#{directory}/file", 'remote_location/file')
    end

    it 'calls analyze_remote_entries with analysis mode' do
      file_processor.process_client_files('remote_location', 'client', 5, true)
      expect(FileAnalyzer).to receive(:new).with(session, logger, file_processor.prompt)
      expect(FileAnalyzer).to receive(:analyze).with('remote_location', 'client')
    end
  end

  describe '#remove_old_files' do
    it 'removes files older than the specified number of days' do
      files_to_delete = ['file1', 'file2']
      session.stubs(:dir).returns(files_to_delete.map { |file| double(file: true, mtime: Time.now - 5.days) })
      file_processor.remove_old_files('remote_location', 5)
      expect(session).to receive(:remove!).with('remote_location/file1')
      expect(session).to receive(:remove!).with('remote_location/file2')
    end

    it 'does nothing if no files need to be removed' do
      session.stubs(:dir).returns([])
      file_processor.remove_old_files('remote_location', 5)
      expect(session).not_to receive(:remove!)
    end
  end

  describe '#remove_file_from_location' do
    it 'removes a file from the specified location' do
      file = double
      session.stubs(:remove!).with('remote_location/file')
      file_processor.remove_file_from_location('remote_location', file)
    end
  end

  describe '#upload_files' do
    it 'uploads files from the local directory to the remote location' do
      client = 'client'
      files = ['file1', 'file2']
      session.stubs(:upload).with("#{directory}/file1", 'remote_location/file1')
      session.stubs(:upload).with("#{directory}/file2", 'remote_location/file2')
      file_processor.upload_files('remote_location', client)
    end
  end

  describe '#matching_files' do
    it 'returns files matching the client name' do
      client = 'client'
      files = ['file1', 'file2', 'file3']
      Dir.children(directory).stubs(:select).returns(files.select { |file| file.downcase.include?(client.downcase) })
      expect(file_processor.matching_files(client)).to eq(['file1', 'file2'])
    end
  end

  describe '#upload_file' do
    it 'uploads a file to the remote location' do
      file = 'file'
      remote_location = 'remote_location'
      index = 0
      total_files = 2
      spinner = TTY::Spinner.new("[:spinner] Copying #{file.yellow} to #{remote_location.cyan} -- (#{index.next}/#{total_files})")
      spinner.auto_spin
      session.stubs(:upload).with("#{directory}/#{file}", "#{remote_location}/#{file}")
      file_processor.upload_file(file, remote_location, index, total_files)
    end
  end

  describe '#analyze_remote_entries' do
    it 'analyzes remote entries' do
      file_analyzer = FileAnalyzer.new(session, logger, file_processor.prompt)
      file_analyzer.stubs(:analyze).with('remote_location', 'client')
      file_processor.analyze_remote_entries('remote_location', 'client')
    end
  end
end