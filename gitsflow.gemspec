lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.push(lib)

require "./lib/sflow.rb"

Gem::Specification.new do |s|
    s.name = %q{gitsflow}
    s.version       = SFlow::VERSION
    s.date = %q{2020-03-20}
    s.bindir = "bin"
    s.homepage = "http://carloswherbet.com.br"
    s.required_ruby_version = '>= 2.0.0'
    s.license       = "MIT"

    s.executables << 'sflow'
    s.summary = %q{SFlow is the custom from GitFlow}
    s.authors     = ["Carlos Wherbet"]
    s.email       = 'carloswherbet@gmail.com'
    s.require_paths = ["lib"]
    s.files =  `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
    s.add_dependency  "dotenv", "~> 0"
    s.add_dependency  "pry", "~> 0"
    # s.add_development_dependency  "pry", "~> 0"
  end
  