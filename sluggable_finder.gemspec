# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sluggable_finder}
  s.version = "2.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ismael Celis"]
  s.date = %q{2009-06-10}
  s.description = %q{This plugin allows models to generate a unique "slug" (url-enabled name) from any regular attribute. Sluggable models can have a scope parameter so slugs are unique relative to a parent model.}
  s.email = %q{ismaelct@gmail.com}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "History.txt",
    "Manifest.txt",
    "PostInstall.txt",
    "README.markdown",
    "Rakefile",
    "VERSION.yml",
    "lib/sluggable_finder.rb",
    "lib/sluggable_finder/finder.rb",
    "lib/sluggable_finder/orm.rb",
    "spec/db/test.db",
    "spec/log/test.log",
    "spec/sluggable_finder_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Easy nice permalinks for your ActiveRecord models}
  s.test_files = [
    "spec/sluggable_finder_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 2.2.2"])
    else
      s.add_dependency(%q<activerecord>, [">= 2.2.2"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 2.2.2"])
  end
end
