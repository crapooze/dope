
require 'welo'

module Dope
  autoload :View, 'dope/core/view'
  module Resource
    include Welo::Resource
    def self.included(mod)
      mod.extend Welo::Resource::ClassMethods
      mod.extend ClassMethods
    end

    module ClassMethods
      def view(val=nil)
        if val
          @view = val
        end
        @view
      end
    end

    def view_klass
      self.class.view
    end

    def view
      view_klass.new(self)
    end
  end
end
