
autoload :Rack, 'rack/utils'
require 'derailleur/base/context'
require 'mime/types'

module Dope
  class ResourceContext < Derailleur::Context
    attr_reader :resource
    def initialize(env, ctx, resource, &blk)
      super(env, ctx, &blk)
      @resource = resource
    end

    def perspective
      (Rack::Utils.parse_query(env['QUERY_STRING'])['perspective'] || 'default').to_sym
    end

    def default_ext
      '.html'
    end

    def default_content_type
      'text/plain'
    end

    def ext
      ret = extname 
      return default_ext if ret.empty?
      ret
    end

    #XXX bitchy: all the if ext == '.html' may go to the code in the view
    def content
      e = ext
      if e == '.html'
        resource.view.render(self)
      else
        resource.to_ext(e, self)
      end
    end

    def mime_types
      MIME::Types.of(ext)
    end

    def content_type
      m = mime_types
      if m
        m.first.to_s 
      else
        default_content_type
      end
    end

    def headers
      {'Content-Type' => content_type}
    end

  end
end
