# frozen_string_literal: true

require 'minitest/autorun'
require 'net/sftp'
require 'mocha/minitest'

require_relative '../lib/sftp'

class SFTPTest < Minitest::Test
  def setup
    @sftp = SFTP.new(ENV['HOST'], ENV['USERNAME'])
  end

  def test_initialize
    assert_equal 'example.com', @sftp.host
    assert_equal 'username', @sftp.username
    assert_equal 'password', @sftp.password
  end

  def test_entries
    # Create a mock SFTP session that returns the expected directory entries
    mock_session = Minitest::Mock.new
    mock_session.expect :dir, [{ name: 'file1' }, { name: 'file2' }], ['remote_dir']
    @sftp.instance_variable_set(:@session, mock_session)

    entries = @sftp.entries('remote_dir')
    assert_equal [{ name: 'file1' }, { name: 'file2' }], entries

    # Ensure that the SFTP session received the expected call
    mock_session.verify
  end

  def test_get
    # Create a mock SFTP session that expects a call to the download method
    mock_session = Minitest::Mock.new
    mock_session.expect :download!, nil, ['remote_file', nil, {}]
    @sftp.instance_variable_set(:@session, mock_session)

    @sftp.get('remote_file')

    # Ensure that the SFTP session received the expected call
    mock_session.verify
  end

  def test_open
    # Create a mock SFTP session that expects a call to the file.open method
    mock_session = Minitest::Mock.new
    mock_session.expect :file, mock_session, []
    mock_session.expect :open, nil, %w[remote_file r]
    @sftp.instance_variable_set(:@session, mock_session)

    @sftp.open('remote_file')

    # Ensure that the SFTP session received the expected calls
    mock_session.verify
  end

  def test_upload
    # Create a mock SFTP session that expects a call to the upload! method
    mock_session = Minitest::Mock.new
    mock_session.expect :upload!, nil, ['local_file', 'remote_file', {}]
    @sftp.instance_variable_set(:@session, mock_session)

    @sftp.upload('local_file', 'remote_file')

    # Ensure that the SFTP session received the expected call
    mock_session.verify
  end
end
