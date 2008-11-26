module SluggableFinder
  # This module is included by the base class as well as AR asociation collections
  #
  module BaseFinder
    
    def find_with_slug(*args)
      return find_without_slug(*args) unless respond_to?(:sluggable_finder_options)
      
      options = sluggable_finder_options
      error = "There is no #{options[:sluggable_type]} with #{options[:to]} '#{args.first}'"
      
      if (args.first.is_a?(String) and !(args.first =~ /\A\d+\Z/))#only contain digits
          options = {:conditions => ["#{ options[:to]} = ?", args.first]}
          with_scope(:find => options) do
            find_without_slug(:first) or 
            raise SluggableFinder.not_found_exception.new(error)
          end
      else
        find_without_slug(*args)
      end
      
    end
  end
  
  module AssociationProxyFinder
    def find_with_slug(*args)
      return find_without_slug(*args) unless @reflection.klass.respond_to?(:sluggable_finder_options)
      options = @reflection.klass.sluggable_finder_options
      error = "There is no #{options[:sluggable_type]} with #{options[:to]} '#{args.first}'"
      
      if (args.first.is_a?(String) and !(args.first =~ /\A\d+\Z/))#only contain digits
          options = {:conditions => ["#{ options[:to]} = ?", args.first]}
          with_scope(:find => options) do
            find_without_slug(:first) or 
            raise SluggableFinder.not_found_exception.new(error)
          end
      else
        find_without_slug(*args)
      end
      
    end
  end
  
end