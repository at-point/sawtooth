# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sawtooth/version"

Gem::Specification.new do |s|
  s.name        = "sawtooth"
  s.version     = Sawtooth::VERSION
  s.authors     = ["Lukas Westermann"]
  s.email       = ["lukas.westermann@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Declarative XML parsing using nokogiri}
  s.description = %q{Provides an interface on top of nokogiri to parse XML files like Apache Digester.}

  s.rubyforge_project = "sawtooth"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "nokogiri"

  s.add_development_dependency "rake", ">= 0.9.2"
  s.add_development_dependency "appraisal", ">= 0.4.0"
  s.add_development_dependency "minitest", ">= 2.10.0"
end
