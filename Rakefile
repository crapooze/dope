
require 'rubygems'
require 'rake/gempackagetask'

$LOAD_PATH.unshift('lib')
require 'dope'

spec = Gem::Specification.new do |s|

        s.name = 'dope'
        s.rubyforge_project = 'dope'
        s.version = Dope::VERSION
        s.author = Dope::AUTHORS.first
        s.homepage = Dope::WEBSITE
        s.summary = "A way to export Welo resources on Derailleur"
        s.email = "crapooze@gmail.com"
        s.platform = Gem::Platform::RUBY

        s.files = [
          'Rakefile', 
          'TODO', 
          'lib/dope.rb',
          'lib/dope/core/application.rb',
          'lib/dope/core/context.rb',
          'lib/dope/core/handler.rb',
          'lib/dope/core/resource.rb',
          'lib/dope/core/view.rb',
        ]

        s.require_path = 'lib'
        s.bindir = 'bin'
        s.executables = []
        s.has_rdoc = true

        s.add_dependency('derailleur', '>= 0.0.5')
        s.add_dependency('welo', '>= 0.0.6')
        s.add_dependency('mime-types', '>= 1.16')
end

Rake::GemPackageTask.new(spec) do |pkg|
        pkg.need_tar = true
end

task :gem => ["pkg/#{spec.name}-#{spec.version}.gem"] do
        puts "generated #{spec.version}"
end


desc "run an example"
task :example, :ex, :server, :port do |t, params|
  path = "./example/#{params[:ex]}.rb"
  servername = params[:server] || 'thin' 
  port = params[:port] || '3000' 
  if File.file? path
    require path
    require 'rack'
    app = Rack::Builder.new {
      run ExampleApplication
    }
    server = Rack::Handler.get(servername)
    server.run(app, :Port => port.to_i)
  else
    puts "no such example: #{path}
    use ls example to see the possibilities"
   
  end
end
