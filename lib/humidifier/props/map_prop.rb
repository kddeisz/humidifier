module Humidifier
  module Props
    # A property that is contained in a Map
    class MapProp < Base
      attr_reader :subprop

      # converts the value through mapping using the subprop unless it is valid
      def convert(map)
        valid?(map) ? map : map.map { |key, value| [key, subprop.convert(value)] }.to_h
      end

      # CFN stack syntax
      def to_cf(map)
        [key, map.map { |subkey, subvalue| [subkey, subprop.to_cf(subvalue).last] }.to_h]
      end

      # Valid if the value is whitelisted or every value in the map is valid on
      # the subprop
      def valid?(map)
        whitelisted_value?(map) || (map.is_a?(Hash) && map.values.all? { |value| subprop.valid?(value) })
      end

      private

      # Finds the subprop that's specified in the spec
      def after_initialize(substructs)
        @subprop = Props.singular_from(key, spec, substructs)
      end
    end
  end
end
