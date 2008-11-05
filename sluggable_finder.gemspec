Gem::Specification.new do |s|
  s.name = %q{sluggable_finder}
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ismael Celis"]
  s.date = %q{2008-11-04}
  s.email = ["ismaelct@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.markdown"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.markdown", "Rakefile", "lib/sluggable_finder.rb", "lib/sluggable_finder/finder.rb", "lib/sluggable_finder/orm.rb", "script/console", "script/destroy", "script/generate", "spec/sluggable_finder_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake", "tasks/db.rake"]
  s.has_rdoc = false
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{sluggable_finder}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Automatically create SEO friendly, unique permalinks for your ActiveRecord objects. Behaves exactly as ActiveRecord#find}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<newgem>, [">= 1.0.5"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<newgem>, [">= 1.0.5"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.0.5"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end