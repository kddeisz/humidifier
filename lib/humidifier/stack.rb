module Humidifier

  # Represents a CFN stack
  class Stack

    STATIC_RESOURCES     = %i[aws_template_format_version description metadata].freeze
    ENUMERABLE_RESOURCES = %i[mappings outputs parameters resources].freeze
    private_constant :STATIC_RESOURCES, :ENUMERABLE_RESOURCES

    attr_accessor :id, :name, *STATIC_RESOURCES, *ENUMERABLE_RESOURCES

    def initialize(opts = {})
      self.name = opts[:name]
      self.id   = opts[:id]

      STATIC_RESOURCES.each do |resource_type|
        send(:"#{resource_type}=", opts[resource_type])
      end
      ENUMERABLE_RESOURCES.each do |resource_type|
        send(:"#{resource_type}=", opts.fetch(resource_type, {}))
      end
    end

    def add(name, resource)
      resources[name] = resource
    end

    def identifier
      id || name
    end

    def to_cf
      cf = {}
      STATIC_RESOURCES.each do |resource_type|
        cf = add_static_resource(cf, resource_type)
      end
      ENUMERABLE_RESOURCES.each do |resource_type|
        cf = add_enumerable_resources(cf, resource_type)
      end

      JSON.pretty_generate(cf)
    end

    %i[mapping output parameter].each do |resource_type|
      define_method(:"add_#{resource_type}") do |name, opts = {}|
        send(:"#{resource_type}s")[name] = Humidifier.const_get(resource_type.capitalize).new(opts)
      end
    end

    AwsShim::STACK_METHODS.each do |stack_method, shim_method|
      define_method(stack_method) { |opts = {}| AwsShim.send(shim_method, self, opts) }
    end

    private

    def add_static_resource(cf, resource_type)
      resource = send(resource_type)
      cf[Utils.camelize(resource_type)] = resource if resource
      cf
    end

    def add_enumerable_resources(cf, resource_type)
      resources = send(resource_type)
      if resources.any?
        key = Utils.camelize(resource_type)
        cf[key] = Serializer.enumerable_to_h(resources) do |name, resource|
          [name, resource.to_cf]
        end
      end
      cf
    end
  end
end
