module SdkSupport
  class Payload

    attr_accessor :id, :identifier, :max_wait, :name, :options, :to_cf

    def initialize(opts = {})
      self.identifier = opts[:identifier]
      self.max_wait   = opts[:max_wait]
      self.name       = opts[:name]
      self.options    = opts.fetch(:options, {})
      self.to_cf      = opts[:to_cf]
    end

    def merge(new_options)
      self.options = new_options.merge(options)
    end
  end
end
