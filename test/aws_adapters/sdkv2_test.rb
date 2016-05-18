require 'test_helper'

class SDKV2Test < Minitest::Test

  def test_exists?
    with_sdk_v2_loaded do |sdk|
      SdkStubber.expect(:exists?, [], true)
      assert sdk.exists?(payload(identifier: 'testing'))
      SdkStubber.verify
    end
  end

  def test_exists_false
    with_sdk_v2_loaded do |sdk|
      SdkStubber.expect(:exists?, [], false)
      refute sdk.exists?(payload(identifier: 'testing'))
      SdkStubber.verify
    end
  end
end
