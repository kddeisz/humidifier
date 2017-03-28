module Humidifier
  module Props
    # A structure property that references a structure from the specification
    class StructureProp < Base
      attr_reader :subprops

      # converts the value through mapping using the subprop unless it is valid
      def convert(struct)
        if valid?(struct)
          struct
        else
          struct.map do |subkey, subvalue|
            subkey = Utils.underscore(subkey.to_s)
            [subkey.to_sym, subprops[subkey].convert(subvalue)]
          end.to_h
        end
      end

      # CFN stack syntax
      def to_cf(struct)
        [key, struct.map { |subkey, subvalue| subprops[subkey.to_s].to_cf(subvalue) }.to_h]
      end

      # true if the value is whitelisted or Hash and all keys are valid for their corresponding props
      def valid?(struct)
        whitelisted_value?(struct) || (struct.is_a?(Hash) && valid_struct?(struct))
      end

      private

      def after_initialize(substructs)
        type = spec['ItemType'] || spec['Type']
        @subprops =
          substructs.fetch(type, {}).fetch('Properties', {}).map do |key, config|
            subprop = config['ItemType'] == type ? self : Props.from(key, config, substructs)
            [Utils.underscore(key), subprop]
          end.to_h
      end

      def valid_struct?(struct)
        struct.all? { |key, value| subprops.key?(key.to_s) && subprops[key.to_s].valid?(value) }
      end
    end
  end
end
