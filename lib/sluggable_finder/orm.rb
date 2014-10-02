module SluggableFinder
  module Orm
    
    module ClassMethods

      def sluggable_finder(field = :title, options = {}, &slug_modifier)
        return if self.included_modules.include?(SluggableFinder::Orm::InstanceMethods)
        extend SluggableFinder::Finder
        extend SluggableFinder::BaseFinder
        include SluggableFinder::Orm::InstanceMethods

        class << self
          alias_method_chain :find, :slug
        end
        
        write_inheritable_attribute(:sluggable_finder_options, {
          :sluggable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
          :from		        =>	field,
        	:scope		      => 	nil,
        	:to			        =>  :slug,
        	:reserved_slugs => [],
        	:allow_integer_ids => true,
        	:upcase         => false,
        	:slug_modifier  => slug_modifier || nil,
          :separator      => '-',
        	:ignore_sti     => false # if true, Uniqueness won't check sibling classes.
        }.merge( options ))
        class_inheritable_reader :sluggable_finder_options

        if sluggable_finder_options[:scope]
          scope_condition_method = %(
            def scope_condition
                "#{sluggable_finder_options[:scope].to_s} = \#{#{sluggable_finder_options[:scope].to_s}}"
            end
          )
        else
          scope_condition_method = %(
            def scope_condition 
              '1 = 1'
            end
          )
        end

        class_eval <<-EOV

          def slugable_class
            ::#{self.name}
          end

          def source_column
            "#{sluggable_finder_options[:from]}"
          end

          def destination_column
            "#{sluggable_finder_options[:to]}"
          end

          def to_param
          	self.#{sluggable_finder_options[:to]}
          end

          #{scope_condition_method}

          after_validation :set_slug
        EOV

      end

    end
    
    module InstanceMethods


      def set_slug
        s = self.create_sluggable_slug
        write_attribute(destination_column, s)
      end
      
      def get_value_or_generate_random(column_name)
        v = self.send(column_name)
        v = sluggable_finder_options[:slug_modifier].call(v) if sluggable_finder_options[:slug_modifier]
        encoded = SluggableFinder.encode(v.to_s)
        (v.present? && encoded.present?) ? v : SluggableFinder.random_slug_for(self.class)
      end
      
      def create_sluggable_slug
        suffix = ''
        begin
        proposed_slug = if self.send(destination_column.to_sym).blank? # self.slug
          SluggableFinder.encode get_value_or_generate_random(source_column.to_sym) # self.title
        else
          SluggableFinder.encode get_value_or_generate_random(destination_column.to_sym) # self.slug
        end
        proposed_slug = proposed_slug.upcase if sluggable_finder_options[:upcase]
        rescue Exception => e
        	raise e
        end
        cond = if new_record?
          ''
        else
          "id != #{id} AND "
        end
        _type_column = slugable_class.inheritance_column
        _class_name = self.class.name
        slugable_class.transaction do
          #case insensitive
          conds_sql = "#{cond}#{destination_column} LIKE ? and #{scope_condition}"
          conds_sql << " and #{_type_column} = '#{_class_name}'" if sluggable_finder_options[:ignore_sti]
          existing = slugable_class.find(:first, :conditions => [conds_sql,  proposed_slug + suffix])
          while existing != nil or sluggable_finder_options[:reserved_slugs].include?(proposed_slug + suffix)
            if suffix.empty?
              suffix = "#{sluggable_finder_options[:separator]}2"
            else
              suffix.succ!
            end
            existing = slugable_class.find(:first, :conditions => ["#{cond}#{destination_column} = ? and #{scope_condition}",  proposed_slug + suffix])
          end
        end # end of transaction         
        proposed_slug + suffix
      end

    end
    
  end
end
