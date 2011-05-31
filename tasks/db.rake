require 'active_record'
db = {
  :adapter=>'sqlite3',
  :dbfile=> File.join(File.dirname(__FILE__),'..','spec','db','test.db'),
  :host => 'localhost',
  :database => 'spec/db/sluggable_finder_test',
  :user => 'root',
  :password => ''
}
ActiveRecord::Base.establish_connection( db )
# define a migration
class TestSchema < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.timestamps
    end
    create_table :items do |t|
      t.string :title
      t.string :slug
      t.string :type
      t.string :permalink
      t.boolean :published
      t.integer :category_id
      t.timestamps
    end
  end

  def self.down
    drop_table :items
    drop_table :categories
  end
end


namespace :db do
  desc "Create test schema"
  task :create do
    # run the migration
    File.unlink(db[:dbfile]) if db[:adapter] == 'sqlite3' && File.exists?(db[:dbfile])
    ActiveRecord::Base.connection
    TestSchema.migrate(:up)
  end
  
  desc "Destroy test schema"
  task :destroy do
    TestSchema.migrate(:down)
  end
end