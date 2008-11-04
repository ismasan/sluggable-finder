module SluggableFinder
  module Orm
    
    def self.included(base)
      base.extend ClassMethods
      base.class_eval{include InstanceMethods}
      class << base
        alias_method_chain :find, :slug
      end
    end
    
    module ClassMethods

      def sluggable_finder(field = :title, options = {})
        write_inheritable_attribute(:sluggable_finder_options, {
          :sluggable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
          :from		        =>	field,
        	:scope		      => 	nil,
        	:to			        =>  :slug,
        	:reserved_slugs => []
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

          def the_scope
            "#{sluggable_finder_options[:scope]}"
          end

          def to_param
          	send("#{sluggable_finder_options[:to]}")
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

      def create_sluggable_slug
        suffix = ''
        begin
        proposed_slug = if self.send(destination_column.to_sym).blank?
          self.send(source_column.to_sym).to_slug
        else
          self.send(destination_column.to_sym).to_slug
        end
        rescue Exception => e
        	raise e
        end
        cond = if new_record?
          ''
        else
          "id != #{id} AND "
        end
        slugable_class.transaction do
          #case insensitive
          existing = slugable_class.find(:first, :conditions => ["#{cond}#{destination_column} LIKE ? and #{scope_condition}",  proposed_slug + suffix])
          while existing != nil or sluggable_finder_options[:reserved_slugs].include?(proposed_slug + suffix)
            if suffix.empty?
              suffix = "-2"
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