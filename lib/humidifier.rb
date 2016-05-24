require 'forwardable'
require 'json'
require 'pathname'

require 'humidifier/humidifier'
require 'humidifier/utils'

require 'humidifier/fn'
require 'humidifier/ref'
require 'humidifier/props'
require 'humidifier/property_methods'

require 'humidifier/aws_shim'
require 'humidifier/loader'
require 'humidifier/mapping'
require 'humidifier/output'
require 'humidifier/parameter'
require 'humidifier/resource'
require 'humidifier/sdk_payload'
require 'humidifier/sleeper'
require 'humidifier/stack'
require 'humidifier/version'

# container module for all gem classes
module Humidifier
  class << self
    # convenience method for calling cloudformation functions
    def fn
      Fn
    end

    # convenience method for creating references
    def ref(reference)
      Ref.new(reference)
    end

    # the list of all registered resources
    def registry
      @registry ||= {}
    end

    # convenience method for finding classes by AWS name
    def [](aws_name)
      registry[aws_name]
    end
  end
end

Humidifier::Loader.load
