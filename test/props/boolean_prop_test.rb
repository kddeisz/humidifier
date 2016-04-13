require 'test_helper'

module Props
  class BooleanPropTest < Minitest::Test

    def test_takes_true
      assert Humidifier::Props::BooleanProp.new.valid?(true)
    end

    def test_takes_false
      assert Humidifier::Props::BooleanProp.new.valid?(false)
    end

    def test_rejects_other_values
      refute Humidifier::Props::BooleanProp.new.valid?(Object.new)
      refute Humidifier::Props::BooleanProp.new.valid?([])
      refute Humidifier::Props::BooleanProp.new.valid?({})
      refute Humidifier::Props::BooleanProp.new.valid?(1)
    end
  end
end
