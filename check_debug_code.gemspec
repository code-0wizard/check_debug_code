# frozen_string_literal: true

require_relative "lib/check_debug_code/version"

Gem::Specification.new do |spec|
  spec.name = "check_debug_code"
  spec.version = CheckDebugCode::VERSION
  spec.authors = ["code-0wizard"]
  spec.email = ["vwe4g342fgD@gmail.com"]

  spec.summary = "A gem to check for debug code in Rails projects."
  spec.description =   
    "The CheckDebugCode gem searches for debug code like 'console.log' in your Rails project every time a request is made. 
    It outputs the filenames containing the debug code to the browser console, view footer, and Rails logs. 
    This helps developers ensure that debug statements are removed from production code.
    rails generate check_debug_code:install"
  spec.homepage = "https://github.com/veiv-veivmew/check_debug_code"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
