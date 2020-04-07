lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.push(lib)

require "sflow"

Gem::Specification.new do |s|
    s.name          = %q{gitsflow}
    s.version       = SFlow::VERSION
    s.date          = %q{2020-03-20}
    s.bindir        = "bin"
    s.homepage      = "https://github.com/carloswherbet/GitSFlow"
    s.summary       = %q{GitSFlow is a tool that integrate Git custom commands with GitLab and it's inspired GitFlow}
    s.authors       = ["Carlos Wherbet"]
    s.email         = 'carloswherbet@gmail.com'
    s.required_ruby_version = '>= 2.0.0'
    s.license       = "MIT"
    # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
    # to allow pushing to a single host or delete this section to allow pushing to any host.
    if s.respond_to?(:metadata)
      s.metadata["allowed_push_host"] = "https://rubygems.org"
    else
      raise "RubyGems 2.0 or newer is required to protect against " \
        "public gem pushes."
    end
    s.executables << 'sflow'
  
    s.require_paths = ["lib"]
    s.files =  `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
    s.add_dependency  "dotenv", "~> 0"
    s.add_development_dependency  "pry", "~> 0"
    s.add_development_dependency "bundler", "~> 1.16"
    s.add_development_dependency "rake", "~> 12.3"
    s.add_development_dependency "rspec", "~> 3.0"
  end
  