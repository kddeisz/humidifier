require 'test_helper'

class StackTest < Minitest::Test
  ResourceDouble = Struct.new(:to_cf)

  def test_defaults
    stack = Humidifier::Core::Stack.new
    Humidifier::Core::Stack::STATIC_RESOURCES.values.each do |prop|
      assert_equal nil, stack.send(prop)
    end
    Humidifier::Core::Stack::ENUMERABLE_RESOURCES.values.each do |prop|
      assert_equal ({}), stack.send(prop)
    end
  end

  def test_add
    stack = Humidifier::Core::Stack.new
    resource = Object.new
    stack.add('MyResource', resource)

    assert_equal ({ 'MyResource' => resource }), stack.resources
  end

  def test_identifier
    stack = Humidifier::Core::Stack.new(id: 'foo', name: 'bar')
    assert_equal 'foo', stack.identifier
  end

  def test_identifier_no_id
    stack = Humidifier::Core::Stack.new(name: 'foobar')
    assert_equal 'foobar', stack.identifier
  end

  def test_add_mapping
    stack = Humidifier::Core::Stack.new
    stack.add_mapping('foo', 'bar' => 'baz')

    assert_equal 'foo', stack.mappings.keys.first
    assert_equal 'baz', stack.mappings.values.first.opts.values.first
  end

  def test_add_output
    stack = Humidifier::Core::Stack.new
    stack.add_output('foo', value: 'bar')

    assert_equal 'foo', stack.outputs.keys.first
    assert_equal 'bar', stack.outputs.values.first.value
  end

  def test_add_parameter
    stack = Humidifier::Core::Stack.new
    stack.add_parameter('foo', type: 'bar')

    assert_equal 'foo', stack.parameters.keys.first
    assert_equal 'bar', stack.parameters.values.first.type
  end

  def test_to_cf
    expected = {
      'AWSTemplateFormatVersion' => 'foo',
      'Description' => 'bar',
      'Metadata' => 'baz',
      'Resources' => { 'One' => 'One', 'Two' => 'Two' },
      'Mappings' => { 'Three' => 'Three' },
      'Outputs' => { 'Four' => 'Four' },
      'Parameters' => { 'Five' => 'Five' }
    }
    assert_equal expected, JSON.parse(build.to_cf)
  end

  Humidifier::Core::AwsShim::STACK_METHODS.each do |method|
    define_method(:"test_#{method}") do
      with_mocked_aws_shim(method) { |stack| stack.send(method) }
    end
  end

  private

  def build
    Humidifier::Core::Stack.new(static_resources.merge(enumerable_resources))
  end

  def static_resources
    {
      aws_template_format_version: 'foo',
      description: 'bar',
      metadata: 'baz'
    }
  end

  def enumerable_resources
    {
      resources: {
        'One' => ResourceDouble.new('One'),
        'Two' => ResourceDouble.new('Two')
      },
      mappings: { 'Three' => ResourceDouble.new('Three') },
      outputs: { 'Four' => ResourceDouble.new('Four') },
      parameters: { 'Five' => ResourceDouble.new('Five') }
    }
  end

  def with_mocked_aws_shim(method)
    stack = Humidifier::Core::Stack.new(name: 'test-stack')
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [Humidifier::Core::SdkPayload.new(stack, {})])

    Humidifier::Core::AwsShim.stub(method, mock) do
      yield stack
    end
    mock.verify
  end
end
