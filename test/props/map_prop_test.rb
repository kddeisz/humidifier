require 'test_helper'

module Props
  class MapPropTest < Minitest::Test
    def test_valid?
      assert build.valid?({})
      assert build.valid?(Humidifier.ref(Object.new))
      assert build.valid?(Humidifier.fn.base64(Object.new))
    end

    def test_rejects_other_values
      refute build.valid?(Object.new)
      refute build.valid?([])
      refute build.valid?(false)
      refute build.valid?(1.0)
    end

    def test_subprop
      assert build.valid?('foo' => 1, 'bar' => 2)
      refute build.valid?('foo' => 1, 'bar' => '2')
    end

    def test_to_cf
      value = { 'Foo' => 1, 'Bar' => 2 }
      assert_equal ['Test', value], build.to_cf(value)
    end

    def test_to_cf_ref
      actual = build.to_cf(Humidifier.ref('Foo'))
      assert_equal ['Test', { 'Ref' => 'Foo' }], actual
    end

    def test_convert_valid
      value = { 'Foo' => 5 }
      assert value, build.convert(value)
    end

    def test_convert_invalid
      out, * =
        capture_io do
          assert_equal ({ 'Foo' => 5 }), build.convert('Foo' => '5')
        end
      assert_match(/WARNING: Property test/, out)
    end

    private

    def build
      Humidifier::Props::MapProp.new('Test', 'PrimitiveType' => 'Integer')
    end
  end
end
