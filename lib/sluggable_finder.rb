$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module SluggableFinder
  VERSION = '2.0.0'
  
  class << self
    
    def enable_activerecord
      ActiveRecord::Base.extend SluggableFinder::Finder
      ActiveRecord::Base.class_eval{include SluggableFinder::Orm}
      # support for associations
      a = ActiveRecord::Associations
      returning([ a::AssociationCollection ]) { |classes|
        # detect http://dev.rubyonrails.org/changeset/9230
        unless a::HasManyThroughAssociation.superclass == a::HasManyAssociation
          classes << a::HasManyThroughAssociation
        end
      }.each do |klass|
        klass.send :include, SluggableFinder::Finder
        klass.class_eval { alias_method_chain :find, :slug }
      end
      
    end
    
  end
  
  def self.encode(str)
    ActiveSupport::Multibyte::Handlers::UTF8Handler.
    		normalize(str,:d).split(//u).reject { |e| e.length > 1 }.join.strip.gsub(/[^a-z0-9]+/i, '-').downcase
  end
  
end

require 'rubygems'
require 'active_record'

Dir.glob('lib/sluggable_finder/*.rb').each do |file|
  require file
end

SluggableFinder.enable_activerecord if (defined?(ActiveRecord) && !ActiveRecord::Base.respond_to?(:sluggable_finder))