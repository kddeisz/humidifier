module Humidifier
  module Props
    # A double property
    class DoubleProp < Base
      # converts the value through #to_f unless it is valid
      def convert(value)
        if valid?(value) || !value.respond_to?(:to_f)
          value
        else
          puts "WARNING: Property #{name} should be a double"
          value.to_f
        end
      end

      # true if it is whitelisted, an Integer, or a Float
      def valid?(value)
        whitelisted_value?(value) || value.is_a?(Integer) || value.is_a?(Float)
      end
    end
  end
end
