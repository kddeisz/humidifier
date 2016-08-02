require 'test_helper'

class NoopTest < Minitest::Test

  Humidifier::AwsShim::STACK_METHODS.each do |method|
    define_method(:"test_#{method}") do
      assert_warning method
    end
  end

  def test_invalid
    noop = Humidifier::AwsAdapters::Noop.new
    assert_raises NoMethodError do
      noop.validate
    end
  end

  def test_respond_to_missing?
    noop = Humidifier::AwsAdapters::Noop.new
    refute noop.respond_to?(:validate)
  end

  private

  def assert_warning(command)
    noop = Humidifier::AwsAdapters::Noop.new
    out, * = capture_io do
      refute noop.send(command)
    end
    assert_match(/WARNING/, out)
  end
end
