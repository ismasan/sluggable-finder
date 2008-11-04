ActiveRecord::Base.establish_connection(
  :adapter=>'sqlite3',
  :dbfile=> File.join(File.dirname(__FILE__),'..','spec','db','test.db')
)
# define a migration
class TestSchema < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :title
      t.string :slug
      t.string :permalink
      t.boolean :published
      t.integer :category_id
      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end


namespace :db do
  desc "Create test schema"
  task :create => :destroy do
    # run the migration
    TestSchema.migrate(:up)
  end
  
  desc "Destroy test schema"
  task :destroy do
    TestSchema.migrate(:down)
  end
end