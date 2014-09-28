# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "acts_as_favable/version"

Gem::Specification.new do |s|
  s.name        = "acts_as_favable"
  s.version     = ActsAsFavable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["shmp2005"]
  s.email       = ["shmp2005@163.com"]
  s.homepage    = ""
  s.summary     = %q{Rails gem to allowing records to be favable}
  s.description = %q{Rails gem to allowing records to be favable}

  s.rubyforge_project = "acts_as_favable"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "sqlite3", '~> 1.3.9'
end
