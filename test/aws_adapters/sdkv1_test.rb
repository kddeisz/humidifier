require 'test_helper'

class SDKV1Test < Minitest::Test

  def test_create
    with_sdk_v1_loaded do
      assert sdk.create(stack_double)
      refute sdk.create(stack_double(to_cf: false))
    end
  end

  def test_delete
    with_sdk_v1_loaded do
      assert sdk.delete(stack_double)
    end
  end

  def test_exists?
    with_sdk_v1_loaded do
      assert sdk.exists?(stack_double)
      AWS::CloudFormation.stub(:exists?, false) do
        refute sdk.exists?(stack_double)
      end
    end
  end

  def test_update
    with_sdk_v1_loaded do
      assert sdk.update(stack_double)
      refute sdk.update(stack_double(to_cf: false))
    end
  end

  def test_valid?
    with_sdk_v1_loaded do
      assert sdk.valid?(stack_double)
      refute sdk.valid?(stack_double(to_cf: false))
    end
  end

  private

  def sdk
    Humidifier::AwsAdapters::SDKV1.new
  end
end
