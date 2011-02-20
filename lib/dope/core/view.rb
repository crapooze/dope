
module Dope
  class View
    def render(ctx)
      "hello from #{self} in #{ctx}"
    end
  end

  class ResourceView < View
    attr_reader :resource
    def initialize(resource)
      @resource = resource
    end

    def render(ctx)
      "hello from #{self} for #{resource} in #{ctx}"
    end
  end
end
