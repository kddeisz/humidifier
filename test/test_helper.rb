# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'humidifier'

require 'fileutils'
require 'minitest/autorun'

# load the sdk helper files used for stubbing sdk responses/calls
module SdkSupport
  class << self
    extend Forwardable
    def_delegators :tracker, :call, :expect, :verify

    def tracker
      @tracker ||= Tracker.new
    end
  end
end

Dir[File.expand_path('sdk_support/*.rb', __dir__)].each do |file|
  require file
end

Minitest::Test.send(:include, SdkSupport::Helpers)

# extra methods for testing config and serializers
Minitest::Test.send(:include, Module.new do
  def with_config(options = {}, &block)
    config = Humidifier::Config.new(options)
    Humidifier.stub(:config, config, &block)
  end

  def with_mocked_serializer(value)
    mock = Minitest::Mock.new
    mock.expect(:call, value, [value])

    Humidifier::Serializer.stub(:dump, mock) { yield value }
    mock.verify
  end
end)
