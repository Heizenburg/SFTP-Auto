# frozen_string_literal: true

require 'minitest/autorun'

require_relative '../lib/helpers/file_helpers'
require_relative '../lib/helpers/terminal_helpers'

class FileMethodsTest < Minitest::Test
  def test_file_extension
    assert file_extension?('file.zip', '.zip')
    refute file_extension?('file.txt', '.zip')
  end

  def test_convert_bytes_to_kilobytes
    assert_equal convert_bytes_to_kilobytes(1024), '1KB'
  end

  def test_client_file
    assert client_file?('3M_ExtractStoreLevelUnLtdByWeek_20230122_CHECKERS FOODS.zip', '3M')
    refute client_file?('3M_ExtractStoreLevelUnLtdByWeek_20230122_CHECKERS FOODS.zip', 'Abotts')
  end

  def test_compare_local_to_remote
    FileUtils.touch('local_file.txt')
    FileUtils.touch('remote_file.txt')
    assert compare_local_to_remote('.', '.', 'local_file.txt', 'remote_file.txt')
    refute compare_local_to_remote('.', '.', 'local_file.txt', 'remote_file.txt')
    File.delete('local_file.txt')
    File.delete('remote_file.txt')
  end

  def test_local_file_count
    FileUtils.touch('test_file1.zip')
    FileUtils.touch('test_file2.zip')
    assert_equal local_file_count('.'), 2
    File.delete('test_file1.zip')
    File.delete('test_file2.zip')
  end

  def test_hidden_file
    assert hidden_file?('.')
    assert hidden_file?('..')
    refute hidden_file?('file.txt')
  end
end
