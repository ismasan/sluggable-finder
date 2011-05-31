# -*- encoding: utf-8 -*-
require File.expand_path("../lib/sluggable_finder/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "sluggable_finder"
  s.version     = SluggableFinder::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Ismael Celis']
  s.email       = ['ismaelct@gmail.com']
  s.homepage    = "https://github.com/ismasan/sluggable-finder"
  s.description     = %q{This plugin allows models to generate a unique "slug" (url-enabled name) from any regular attribute. Add friendly URLs to your models with one line.}
  s.summary = %q{Easy friendly URLs for your ActiveRecord models}

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "sluggable_finder"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec"
  s.add_development_dependency 'rake'
  s.add_development_dependency 'sqlite3'
  s.add_dependency 'activerecord', "<= 2.8.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end

