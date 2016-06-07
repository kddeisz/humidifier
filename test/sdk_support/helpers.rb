module SdkSupport
  module Helpers

    private

    def payload(opts = {})
      Payload.new(opts)
    end

    def stub(value)
      Stub.new(value)
    end

    def unset_shim
      Humidifier::Core::AwsShim.instance_variable_set(:@instance, nil)
    end

    def with_sdk_v1_loaded
      Object.const_set(:AWS, AwsDouble)
      begin
        unset_shim
        yield Humidifier::Core::AwsShim.shim
      ensure
        Object.send(:remove_const, :AWS)
      end
    end

    def with_sdk_v2_loaded
      Object.const_set(:Aws, AwsDouble)
      begin
        unset_shim
        yield Humidifier::Core::AwsShim.shim
      ensure
        Object.send(:remove_const, :Aws)
      end
    end
  end
end
