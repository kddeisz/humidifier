require 'test_helper'

class HumidifierTest < Minitest::Test

  def test_fn
    assert_equal Humidifier::Fn, Humidifier.fn
  end

  def test_ref
    reference = Object.new
    assert_kind_of Humidifier::Ref, Humidifier.ref(reference)
    assert_equal reference, Humidifier.ref(reference).reference
  end
end
