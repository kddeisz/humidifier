# frozen_string_literal: true

require 'test_helper'

class ClientTest < Minitest::Test
  class WaitingClient < SimpleDelegator
    attr_accessor :max_attempts, :delay

    def wait_until(*)
      yield self
    end
  end

  def test_create
    Aws.config[:cloudformation] = {
      stub_responses: { create_stack: { stack_id: 'test-id' } }
    }

    stack = build_stack
    stack.create

    assert_equal 'test-id', stack.id
  end

  def test_create_and_wait
    Aws.config[:cloudformation] = {
      stub_responses: { create_stack: { stack_id: 'test-id' } }
    }

    build_stack.create_and_wait
  end

  def test_create_change_set
    Aws.config[:cloudformation] = {
      stub_responses: { create_change_set: true }
    }

    build_stack.create_change_set
  end

  def test_delete
    Aws.config[:cloudformation] = {
      stub_responses: { delete_stack: true }
    }

    build_stack.delete
  end

  def test_delete_and_wait
    Aws.config[:cloudformation] = {
      stub_responses: { delete_stack: true }
    }

    build_stack.delete_and_wait
  end

  def test_deploy_exists
    Aws.config[:cloudformation] = {
      stub_responses: { update_stack: true }
    }

    with_stack_status(true) { build_stack.deploy }
  end

  def test_deploy_does_not_exists
    Aws.config[:cloudformation] = {
      stub_responses: { create_stack: { stack_id: 'test-id' } }
    }

    stack = build_stack
    with_stack_status(false) { stack.deploy }

    assert_equal 'test-id', stack.id
  end

  def test_deploy_and_wait
    Aws.config[:cloudformation] = {
      stub_responses: { update_stack: true }
    }

    with_stack_status(true) { build_stack.deploy_and_wait }
  end

  def test_deploy_change_set_exists
    Aws.config[:cloudformation] = {
      stub_responses: { create_change_set: true }
    }

    with_stack_status(true) { build_stack.deploy_change_set }
  end

  def test_deploy_change_set_does_not_exist
    Aws.config[:cloudformation] = {
      stub_responses: { create_stack: { stack_id: 'stack-id' } }
    }

    with_stack_status(false) { build_stack.deploy_change_set }
  end

  def test_update
    Aws.config[:cloudformation] = {
      stub_responses: { update_stack: true }
    }

    build_stack.update
  end

  def test_update_and_wait
    Aws.config[:cloudformation] = {
      stub_responses: { update_stack: true }
    }

    build_stack.update_and_wait
  end

  def test_upload_no_config
    error = assert_raises(RuntimeError) { build_stack.upload }

    assert_includes error.message, 'stack-name'
  end

  def test_upload_with_config
    Aws.config[:s3] = {
      stub_responses: { get_object: true, put_object: true }
    }

    with_config s3_bucket: 'foobar' do
      build_stack.upload
    end
  end

  def test_valid?
    Aws.config[:cloudformation] = {
      stub_responses: { validate_template: true }
    }

    assert build_stack.valid?
  end

  def test_valid_false
    error = Aws::CloudFormation::Errors::ValidationError
    Aws.config[:cloudformation] = {
      stub_responses: { validate_template: error.new(nil, 'foobar') }
    }

    _stdout, stderr, = capture_io { refute build_stack.valid? }
    assert stderr.start_with?('foobar')
  end

  def test_valid_upload_necessary # rubocop:disable Metrics/MethodLength
    Aws.config.merge!(
      s3: {
        stub_responses: { get_object: true, put_object: true }
      },
      cloudformation: {
        stub_responses: { validate_template: true }
      }
    )

    stack = build_stack
    stack.add(
      'a' * Humidifier::Stack::MAX_TEMPLATE_BODY_SIZE,
      stack.resources.delete('asg')
    )

    with_config s3_bucket: 'foobar' do
      assert stack.valid?
    end
  end

  def test_valid_stack_too_large
    stack = build_stack
    stack.add(
      'a' * Humidifier::Stack::MAX_TEMPLATE_URL_SIZE,
      stack.resources.delete('asg')
    )

    assert_raises Humidifier::Stack::TemplateTooLargeError do
      stack.valid?
    end
  end

  private

  def build_stack
    Humidifier::Stack.new(name: 'stack-name').tap do |stack|
      asg = Humidifier::AutoScaling::AutoScalingGroup
      stack.add('asg', asg.new(min_size: '1', max_size: '20'))
      stack.client = WaitingClient.new(stack.client)
    end
  end

  def with_config(opts)
    config = Humidifier.config.dup
    opts.each do |key, value|
      Humidifier.config.public_send(:"#{key}=", value)
    end

    yield
  ensure
    Humidifier.instance_variable_set(:@config, config)
  end

  def with_stack_status(exists, &block)
    stack = Struct.new(:exists?).new(exists)
    Aws::CloudFormation::Stack.stub(:new, stack, &block)
  end
end
