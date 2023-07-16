# frozen_string_literal: true

require_relative "lib/connect/version"

Gem::Specification.new do |spec|
  spec.name = "connect"
  spec.version = Connect::VERSION
  spec.authors = ["Brave Hager"]
  spec.email = ["bravehager@gmail.com"]

  spec.summary = "Idiomatic Connect RPCs for Ruby."
  spec.homepage = "https://github.com/bravehager/connect-ruby"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["rubygems_mfa_required"] = "true"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bravehager/connect-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/bravehager/connect-ruby/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    %x(git ls-files -z).split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(
        "bin/",
        "test/",
        "spec/",
        "examples/",
        "Rakefile",
        "README.md",
        ".git",
        ".rspec",
        ".rubocop.yml",
      )
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("google-protobuf", "~> 3.23")
  spec.add_dependency("zeitwerk", "~> 2.6")
end
