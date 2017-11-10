require 'test_helper'

class ParameterTest < Minitest::Test
  def test_to_cf
    assert_equal ({ 'Type' => 'String' }), Humidifier::Parameter.new.to_cf
  end

  def test_to_cf_with_description
    with_mocked_serializer('foobar') do |value|
      output = Humidifier::Parameter.new(description: value)
      expected = { 'Type' => 'String', 'Description' => value }
      assert_equal expected, output.to_cf
    end
  end
end
