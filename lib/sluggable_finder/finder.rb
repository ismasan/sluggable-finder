module SluggableFinder
  # This module is included by the base class as well as AR asociation collections
  #
  module Finder
    
    def find_with_slug(*args)
      if (args.first.is_a?(String) and !(args.first =~ /\A\d+\Z/))#only contain digits
          options = {:conditions => ["#{ sluggable_finder_options[:to]} = ?", args.first]}
          first(options) or 
            raise SluggableFinder.not_found_exception.new("There is no #{sluggable_finder_options[:sluggable_type]} with #{sluggable_finder_options[:to]} '#{args.first}'")
      else
        find_without_slug(*args)
      end
    end
  end
  
end