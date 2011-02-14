
require 'derailleur'
require 'dope/core/handler'
autoload :Find, 'find'

module Dope
  module Application
    include Derailleur::Application

    def get_resource_at_path(resource, path)
      puts "R: #{path}"
      get(path, ResourceHandler.new(resource))
    end

    def get_resource(resource, root='', ident=:default)
      path = File.join(root, resource.path(ident))
      get_resource_at_path(resource, path)
    end

    def unget_resource(resource, root='', ident=:default)
      path = File.join(root, resource.path(ident))
      unget(path)
    end

    def get_linked_resource(link, root='')
      branch = link.to_s.sub(/^\.\//,'')
      path = File.join(root, branch)
      get_resource_at_path(link.to, path)
    end

    def unget_linked_resource(link, root='')
      branch = link.to_s.sub(/^\.\//,'')
      path = File.join(root, branch)
      unget(path)
    end

    def get_resource_relation(resource, relname, root='', ident=:default)
      rel = resource.relationship(relname)
      raise ArgumentError, "no relationship: #{relname} for #{resource}" unless rel
      link = resource.link_for_rel(rel)
      path = File.join(root, resource.path(ident))
      case link
      when Welo::Link
        get_linked_resource(link, path)
      when Welo::LinksEnumerator
        link.each do |l|
          get_linked_resource(l, path)
        end
      else
        raise RuntimeError, "unknown kind of link: #{link}"
      end
    end

    def unget_resource_relation(resource, relname, root='', ident=:default)
      rel = resource.relationship(relname)
      raise ArgumentError, "no relationship: #{relname} for #{resource}" unless rel
      link = resource.link_for_rel(rel)
      path = File.join(root, resource.path(ident))
      case link
      when Welo::Link
        unget_linked_resource(link, path)
      when Welo::LinksEnumerator
        link.each do |l|
          unget_linked_resource(l, path)
        end
      else
        raise RuntimeError, "unknown kind of link: #{link}"
      end
    end

    def get_resource_model_at_path(model, ident, resources, path)
      puts "M: #{path}"
      get(path, ResourceModelHandler.new([model, ident, resources]))
    end

    def get_resource_model(model, resources, root='', ident=:default)
      path = File.join(root, model.path_model(ident, "#{model.base_path}."))
      get_resource_model_at_path(model, ident, resources, path)
    end

    def unget_resource_model(model, root='', ident=:default)
      path = File.join(root, model.path_model(ident, "#{model.base_path}."))
      unget(path)
    end

    def get_resource_nesting_model(resource, relname, model, resources, root='', ident=:default)
      nesting = resource.nesting(relname)
      raise ArgumentError, "no nesting: #{relname} for #{resource}" unless nesting
      model_ident = nesting.identifier_sym
      path = File.join(root, resource.path(ident))
      get_resource_model(model, resources, path, model_ident)
    end

    def unget_resource_nesting_model(resource, relname, model, root='', ident=:default)
      nesting = resource.nesting(relname)
      raise ArgumentError, "no nesting: #{relname} for #{resource}" unless nesting
      model_ident = nesting.identifier_sym
      path = File.join(root, resource.path(ident))
      unget_resource_model(model, path, model_ident)
    end

    def get_resource_epitheting_model(resource, label, model, resources, root='', ident=:default)
      epithet = resource.epithet(label)
      raise ArgumentError, "no epithet: #{label} for #{resource}" unless epithet
      branch = resource.epithets(label, "#{model.base_path}.")
      path = File.join(root, resource.path(ident), label.to_s, branch)
      get_resource_epitheting_model_at_path(resource, model, label, resources, path)
    end

    def get_resource_epitheting_model_at_path(resource, model, label, resources, path)
      puts "E: #{path}"
      get(path, ResourceEpithetingModelHandler.new([model, label, resources, resource]))
    end

    # multi-level

    def get_resource_relation_tree(resource, tree=[], root='', ident=:default)
      path = if ident
               File.join(root, resource.path(ident))
             else
               root
             end
      tree.each do |node|
        relname, subtree = if node.is_a? Array
                             [node.first, node[1 .. -1]]
                           else
                             [node, []]
                           end
        rel = resource.relationship(relname)
        raise ArgumentError, "no relationship: #{relname} for #{resource}" unless rel
        link = resource.link_for_rel(rel)
        case link
        when Welo::Link
          get_linked_resource(link, path)
          unless subtree.empty?
            branch = link.to_s.sub(/^\.\//,'')
            new_root = File.join(path, branch)
            get_resource_relation_tree(link.to, subtree, new_root, nil)
          end
        when Welo::LinksEnumerator
          link.each do |l|
            get_linked_resource(l, path)
            unless subtree.empty?
              branch = link.to_s.sub(/^\.\//,'')
              new_root = File.join(path, branch)
              get_resource_relation_tree(link.to, subtree, new_root, nil)
            end
          end
        else
          raise RuntimeError, "unknown kind of link: #{link}"
        end
      end
    end

    def get_resource_relation_chain(resource, relnames=[], root='', ident=:default)
      tree = []
      last = tree
      relnames.each do |sym|
        ary = [sym]
        last << ary
        last = ary
      end
      get_resource_relation_tree(resource, tree, root, ident)
    end


    # file-system assets' handling

    def static_dir(dir)
      Find.find(dir) do |path|
        if File.file?(path)
          static_file path, dir
        end
      end
    end

    def static_file(path, dir='')
      route = path.sub(dir,'')
      puts "F: #{route}"
      StaticFileHandler.register(route, path)
      get(route.sub(/\.\w+$/,''), StaticFileHandler)
    rescue Derailleur::RouteObjectAlreadyPresent
    end
  end
end
