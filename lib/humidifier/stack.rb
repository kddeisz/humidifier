module Humidifier
  # Represents a CFN stack
  class Stack
    # Single settings on the stack
    STATIC_RESOURCES =
      Utils.underscored(%w[AWSTemplateFormatVersion Description Metadata])

    # Lists of objects linked to the stack
    ENUMERABLE_RESOURCES =
      Utils.underscored(%w[Conditions Mappings Outputs Parameters Resources])

    attr_reader :id, :name
    attr_reader(*ENUMERABLE_RESOURCES.values, *STATIC_RESOURCES.values)

    def initialize(opts = {})
      @name = opts[:name]
      @id = opts[:id]
      @default_identifier = self.class.next_default_identifier

      ENUMERABLE_RESOURCES.each_value do |property|
        instance_variable_set(:"@#{property}", opts.fetch(property, {}))
      end

      STATIC_RESOURCES.each_value do |property|
        instance_variable_set(:"@#{property}", opts[property])
      end
    end

    # Add a resource to the stack and optionally set its attributes
    def add(name, resource, attributes = {})
      resources[name] = resource
      resource.update_attributes(attributes) if attributes.any?
      resource
    end

    # The identifier used by the shim to find the stack in CFN, prefers id to
    # name
    def identifier
      id || name || default_identifier
    end

    # A string representation of the stack that's valid for CFN
    def to_cf(serializer = :json)
      resources = static_resources.merge(enumerable_resources)

      case serializer
      when :json then JSON.pretty_generate(resources)
      when :yaml then YAML.dump(resources)
      end
    end

    %i[condition mapping output parameter].each do |resource_type|
      define_method(:"add_#{resource_type}") do |name, opts = {}|
        send(:"#{resource_type}s")[name] =
          Humidifier.const_get(resource_type.capitalize).new(opts)
      end
    end

    AwsShim::STACK_METHODS.each do |method|
      define_method(method) do |opts = {}|
        AwsShim.send(method, SdkPayload.new(self, opts))
      end
    end

    # Increment the default identifier
    def self.next_default_identifier
      @count ||= 0
      @count += 1
      "humidifier-stack-template-#{@count}"
    end

    private

    attr_reader :default_identifier

    def enumerable_resources
      ENUMERABLE_RESOURCES.each_with_object({}) do |(name, prop), list|
        resources = send(prop)
        next if resources.empty?

        list[name] =
          resources.map do |resource_name, resource|
            [resource_name, resource.to_cf]
          end.to_h
      end
    end

    def static_resources
      STATIC_RESOURCES.each_with_object({}) do |(name, prop), list|
        resource = send(prop)
        list[name] = resource if resource
      end
    end
  end
end
