# frozen_string_literal: true

require_relative "lib/jekyll-archives/version"

Gem::Specification.new do |s|
  s.name        = "jekyll-archives-v2"
  s.summary     = "Collections archives for Jekyll."
  s.description = "Automatically generate collections archives by dates, tags, and categories."
  s.version     = Jekyll::Archives::VERSION
  s.authors     = ["George Corrêa de Araújo"]

  s.homepage    = "https://github.com/george-gca/jekyll-archives-v2"
  s.licenses    = ["MIT"]

  all_files     = `git ls-files -z`.split("\x0")
  s.files       = all_files.grep(%r!^(lib)/!)

  s.required_ruby_version = ">= 2.3.0"

  s.add_dependency "jekyll", ">= 3.6", "< 5.0"

  s.add_development_dependency "bundler"
  s.add_development_dependency "minitest"
  s.add_development_dependency "rake"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "rubocop-jekyll", "~> 0.9"
  s.add_development_dependency "shoulda"
end
