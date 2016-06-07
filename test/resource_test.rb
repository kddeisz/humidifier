require 'test_helper'

class ResourceTest < Minitest::Test
  Humidifier::Core::Resource.props = {
    'one' => Humidifier::Core::Props::StringProp.new('One'),
    'two' => Humidifier::Core::Props::IntegerProp.new('Two')
  }
  Humidifier::Core::Resource.aws_name = 'AWS::Resource'

  def test_method_missing_reader
    resource = build
    assert_equal 'one', resource.one
  end

  def test_method_missing_writer
    resource = build
    resource.one = 'three'
    assert_equal 'three', resource.one
  end

  def test_respond_to_missing?
    resource = build
    Humidifier::Core::Resource.props.keys.each do |key|
      assert resource.respond_to?(key)
      assert resource.respond_to?("#{key}=")
    end
  end

  def test_respond_to_missing_invalid
    resource = build
    assert_raises NoMethodError do
      resource.foo
    end
  end

  def test_to_cf
    resource = build
    assert_equal ({ 'Type' => 'AWS::Resource', 'Properties' => { 'One' => 'one', 'Two' => 2 } }), resource.to_cf
  end

  def test_initialize_raw
    resource = Humidifier::Core::Resource.new({ 'One' => 'one', 'Two' => 2 }, true)
    assert_equal ({ 'one' => 'one', 'two' => 2 }), resource.properties
  end

  def test_update
    assert_equal ({ 'one' => 'one', 'two' => 2 }), build.properties
  end

  def test_update_raw
    resource = build
    resource.update({ 'One' => 'three', 'Two' => 4 }, true)
    assert_equal ({ 'one' => 'three', 'two' => 4 }), resource.properties
  end

  def test_update_property
    resource = build
    resource.update_property('one', 'three')
    assert_equal ({ 'one' => 'three', 'two' => 2 }), resource.properties
  end

  def test_update_property_raw
    resource = build
    resource.update_property('One', 'three', true)
    assert_equal ({ 'one' => 'three', 'two' => 2 }), resource.properties
  end

  def test_update_property_invalid_property
    resource = build
    assert_raises ArgumentError do
      resource.update_property('three', 3)
    end
  end

  def test_update_property_invalid_value
    resource = build
    assert_raises ArgumentError do
      resource.update_property('one', 1)
    end
  end

  def test_prop?
    assert Humidifier::Core::Resource.prop?('one')
    refute Humidifier::Core::Resource.prop?('three')
  end

  def test_common_attributes
    resource = build
    resource.depends_on = 'foo'
    resource.metadata = 'bar'

    expected = { 'DependsOn' => 'foo', 'Metadata' => 'bar' }
    assert_equal expected, resource.to_cf.reject { |key| %w[Type Properties].include?(key) }
  end

  def test_build_property_reader
    slate = build_slate
    slate.build_property_reader(:foo)
    resource = slate.new('foo' => 'bar')

    assert resource.respond_to?(:foo)
    assert_equal 'bar', resource.foo
  end

  def test_build_property_writer
    slate = build_slate
    slate.build_property_writer(:foo=)
    resource = slate.new

    assert resource.respond_to?(:foo=)
    resource.foo = 'bar'
    assert_equal 'bar', resource.properties['foo']
  end

  private

  def build
    Humidifier::Core::Resource.new(one: 'one', two: 2)
  end

  def build_slate
    Class.new(Humidifier::Core::Resource) do
      self.props = { 'foo' => Humidifier::Core::Props::StringProp.new('Foo') }
    end
  end
end
