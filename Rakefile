require 'rubygems'
require 'rake/gempackagetask'

GEM_NAME = "tools"
GEM_VERSION = "0.1.0"
AUTHOR = "Tymon Tobolski"
EMAIL = "i@teamon.eu"
HOMEPAGE = "http://teamon.eu/"
SUMMARY = "Collection of tools"

spec = Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.markdown", "LICENSE"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.executables = %w( tools )
  s.files = %w(LICENSE README.markdown Rakefile) + Dir.glob("{bin,lib}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Create a gemspec file"
task :gemspec do
  File.open("#{GEM_NAME}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end
