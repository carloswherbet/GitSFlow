lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.push(lib)
require_relative "lib/sflow"

Gem::Specification.new do |s|
    s.name          = %q{gitsflow}
    s.version       = SFlow::VERSION
    s.date          = %q{2020-03-20}
    s.bindir        = "bin"
    s.homepage      = "https://github.com/carloswherbet/GitSFlow"
    s.summary       = %q{GitSFlow is a tool that integrate Git custom commands with GitLab and it's inspired GitFlow}
    s.authors       = ["Carlos Wherbet"]
    s.email         = 'carloswherbet@gmail.com'
    s.required_ruby_version = Gem::Requirement.new(">= 2.3.0")
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

    s.add_development_dependency "bundler", "~> 2.2.26"
    s.add_development_dependency  "dotenv", "~> 2.7.5"
    s.add_dependency  "dotenv", "~> 2.7.5"
    s.add_development_dependency  "pry",  '~> 0.12.2'
    s.add_development_dependency "rake", "~> 12.3"
    s.add_development_dependency "rspec", "~> 3.0"
    s.add_development_dependency "tty-prompt", "~> 0.23.1"
    s.add_dependency "tty-prompt", "~> 0.23.1"

    s.add_development_dependency "tty-progressbar", "~> 0.18.2"
    s.add_dependency "tty-progressbar", "~> 0.18.2"

    s.add_development_dependency "pastel", "~> 0.8.0"
    s.add_dependency  "pastel", "~> 0.8.0"

    s.add_development_dependency "tty-config", "~> 0.5.0"
    s.add_dependency  "tty-config", "~> 0.5.0"

    s.add_development_dependency "tty-box", "~> 0.7.0"
    s.add_dependency  "tty-box", "~> 0.7.0"

    s.add_development_dependency "tty-command", "~> 0.10.1"
    s.add_dependency  "tty-command", "~> 0.10.1"
    
    s.add_development_dependency "tty-option", "~> 0.2.0"
    s.add_dependency  "tty-option", "~> 0.2.0"

    s.add_development_dependency "tty-editor", "~> 0.7.0"
    s.add_dependency  "tty-editor", "~> 0.7.0"

    s.add_development_dependency "tty-file", "~> 0.10.0"
    s.add_dependency  "tty-file", "~> 0.10.0"

    s.add_development_dependency "tty-table", "~> 0.12.0"
    s.add_dependency  "tty-table", "~> 0.12.0"

  end
  