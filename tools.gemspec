# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tools}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tymon Tobolski"]
  s.date = %q{2009-07-21}
  s.default_executable = %q{tools}
  s.description = %q{Collection of tools}
  s.email = %q{i@teamon.eu}
  s.executables = ["tools"]
  s.extra_rdoc_files = ["README.markdown", "LICENSE"]
  s.files = ["LICENSE", "README.markdown", "Rakefile", "bin/tools", "lib/tools", "lib/tools/css.rb", "lib/tools/stats.rb", "lib/tools/tasks.rb", "lib/tools/utils.rb", "lib/tools/webkit2png.py", "lib/tools.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://teamon.eu/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Collection of tools}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
