
module Dope
  class View
    attr_reader :resource
    def initialize(resource)
      @resource = resource
    end

    def render(ctx)
      "hello from #{self} for #{resource} in #{ctx}"
    end
  end
end
