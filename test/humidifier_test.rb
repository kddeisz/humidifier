require 'test_helper'

class HumidifierTest < Minitest::Test

  def test_fn
    assert_equal Humidifier::Core::Fn, Humidifier.fn
  end

  def test_ref
    reference = Object.new
    assert_kind_of Humidifier::Core::Ref, Humidifier.ref(reference)
    assert_equal reference, Humidifier.ref(reference).reference
  end

  def test_brackets
    Humidifier.stub(:registry, foo: 'bar') do
      assert_equal 'bar', Humidifier[:foo]
    end
  end
end
