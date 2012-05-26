# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Kenn Ejima"]
  gem.email         = ["kenn.ejima@gmail.com"]
  gem.description   = %q{Fast, memory efficient bitwise operations on large binary strings}
  gem.summary       = %q{Fast, memory efficient bitwise operations on large binary strings}
  gem.homepage      = "http://github.com/kenn/bitwise"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "bitwise"
  gem.require_paths = ["lib"]
  gem.version       = '0.5.0' # retrieve this value by: Gem.loaded_specs['redis-mutex'].version.to_s

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake-compiler"

  # For Travis
  gem.add_development_dependency "rake"
end
