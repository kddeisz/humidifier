require 'test_helper'

class OutputTest < Minitest::Test

  def test_to_cf
    with_mocked_serializer(Object.new) do |value|
      assert_equal ({ 'Value' => value }), Humidifier::Core::Output.new(value: value).to_cf
    end
  end

  def test_to_cf_with_description
    with_mocked_serializer(Object.new) do |value|
      output = Humidifier::Core::Output.new(value: value, description: 'foobar')
      assert_equal ({ 'Value' => value, 'Description' => 'foobar' }), output.to_cf
    end
  end
end
