# frozen_string_literal: true

require 'minitest/autorun'

require_relative '../lib/upload'

class TestClientsToCycle < Minitest::Test
  def setup
    @remote = [
      ['client1', '/remote/location1'],
      ['client2', '/remote/location2'],
      ['client3', '/remote/location3']
    ]
    @local = '/local/location'
  end

  def test_clients_to_cycle_with_no_arguments
    ARGV.clear
    result = clients_to_cycle(@remote)
    assert_equal @remote, result
  end

  def test_clients_to_cycle_with_analyze_argument
    ARGV.clear
    ARGV << 'analyze'
    result = clients_to_cycle(@remote)
    assert_equal @remote, result
  end

  def test_clients_to_cycle_with_analyze_and_second_argument
    ARGV.clear
    ARGV << 'analyze'
    ARGV << '2'
    result = clients_to_cycle(@remote)
    assert_equal @remote.cycle.take(2), result
  end

  def test_clients_to_cycle_with_analyze_and_second_and_third_arguments
    ARGV.clear
    ARGV << 'analyze'
    ARGV << '1'
    ARGV << '3'
    result = clients_to_cycle(@remote)
    assert_equal @remote[0...2], result
  end
end
