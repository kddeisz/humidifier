# frozen_string_literal: true

module Humidifier
  class Condition
    attr_reader :opts

    def initialize(opts)
      @opts = opts
    end

    def to_cf
      Serializer.dump(opts)
    end
  end
end
