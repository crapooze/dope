
require 'dope/core/context'
require 'derailleur/core/handler'
require 'mime/types'

module Dope
  class StaticFileHandler < Derailleur::RackHandler
    class NoSuchStaticFile < Derailleur::NoSuchRoute
    end

    @registrations = {}

    class << self
      attr_reader :registrations

      def register(route, path)
        registrations[route] = path
      end
    end

    def path
      self.class.registrations[env['PATH_INFO']]
    end

    def extname
      File.extname(env['PATH_INFO'])
    end

    def mime_types
      MIME::Types.of(path)
    end

    def content_type
      m = mime_types
      m.first.to_s if m
    end

    def to_rack_output
      raise NoSuchStaticFile, "no such file (#{path}) for #{env['PATH_INFO']}" unless path and File.file?(path)
      [200, {'Content-Type' => content_type}, File.read(path)]
    end
  end

  class ResourceHandler < Derailleur::Handler
    alias :resource :object

    def to_rack_output
      context = ResourceContext.new(env, ctx, resource)
      context.result
    end
  end

  class ResourceNotFound < Derailleur::NoSuchRoute
  end

  class ResourceModelHandler < Derailleur::Handler
    def model
      object[0]
    end

    def resources
      object[2]
    end

    def prefix
      ":#{model.base_path}."
    end

    def to_rack_output
      resource = find_resource
      raise ResourceNotFound unless resource
      ResourceHandler.new(resource, env, ctx).to_rack_output
    end
  end

  class ResourceNestingModelHandler < ResourceModelHandler
    def ident
      object[1]
    end

    def find_resource
      params = ctx['derailleur.params'].dup
      params.delete(:splat)
      resources.find{|r| r.match_params?(params, ident, prefix)}
    end
  end

  class ResourceEpithetingModelHandler < ResourceModelHandler
    def label
      object[1]
    end

    def resource
      object[3]
    end

    def find_resource
      params = ctx['derailleur.params'].dup
      params.delete(:splat)
      found = resources.find do |r|
        resource.epithet_resource_match_params?(r, params, label, prefix)
      end
    end
  end
end
