
$LOAD_PATH << './lib'
require './example/peer'
require 'dope/core/application'
require 'rack'
require 'json'
require 'yaml'

a, b, c, d = * Files
foo, bar, baz = *Peers
foo.peers << bar
foo.peers << baz
bar.peers << foo
foo.files << a
foo.files << b

class MyApp
  include Dope::Application
end

dope = MyApp.new

dope.static_dir(File.join(File.dirname(__FILE__), 'public'))

(Peers + Files).each do |r|
  dope.get_resource(r)
end

Peers.each do |peer|
  dope.get_resource_relation(peer, :peers)
  dope.get_resource_relation(peer, :preferred_files)
end

dope.unget_resource Peers.last

zomg = Peer.new('zomg')
zomg.files << a
dope.get_resource_model(Peer, Peers + [zomg])
dope.get_resource(zomg)
dope.get_resource_nesting_model(zomg, :peers, Peer, Peers)
dope.get_resource_epitheting_model(zomg, :preferred_files, MyFile, Files)

app = Rack::Builder.new {
  run dope
}

server = Rack::Handler.get('thin')
server.run(app, :Port => 3000)
