require 'test_helper'

class SDKV2Test < Minitest::Test

  def setup
    load_sdk_v2
  end

  def teardown
    unload_sdk_v2
  end

  def test_exists?
    assert sdk.exists?(payload_double)
    Aws::CloudFormation.stub(:exists?, false) do
      refute sdk.exists?(payload_double)
    end
  end

  private

  def sdk
    Humidifier::AwsAdapters::SDKV2.new
  end
end
